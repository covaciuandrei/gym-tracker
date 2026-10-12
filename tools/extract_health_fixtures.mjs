#!/usr/bin/env node
// tools/extract_health_fixtures.mjs
//
// One-off extractor: reads a sample Apple Health export
// (apple_health_export/export.xml, gitignored, never committed) and produces
// small, HealthKit-shaped JSON fixtures under
// test/fixtures/health_insights/ for the Health Insights tests'
// MockHealthRepository.
//
// The output is anonymized by construction: device/source names are reduced
// to generic labels and the birth date is replaced by a placeholder, so the
// fixtures never carry a name or a real date of birth. Only the metrics the
// feature reads are extracted.
//
// Why a hand-rolled line scanner instead of a real XML parser: export.xml is
// tens of millions of lines but every <Record .../> / <Workout .../> / <Me
// .../> element is emitted on a single self-closing line, so a streaming
// line reader with attribute-level regexes is both much faster and has zero
// new dependencies compared to a DOM/SAX XML parser over a 1GB+ file.
//
// Usage: node tools/extract_health_fixtures.mjs
//
// Re-running is idempotent (it always reads the same export and overwrites
// the same output files).

import { createReadStream, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { createInterface } from 'node:readline';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = join(__dirname, '..');
const EXPORT_XML = join(REPO_ROOT, 'apple_health_export', 'export.xml');
const OUT_DIR = join(REPO_ROOT, 'test', 'fixtures', 'health_insights');

// Only keep data from this date forward (locked scope: Jan 2022 -> export date).
const CUTOFF = new Date('2022-01-01T00:00:00+03:00');

// type="HKQuantityTypeIdentifier<X>" -> output file name (without .json).
const QUANTITY_TYPES = {
  HKQuantityTypeIdentifierBodyMass: 'body_mass',
  HKQuantityTypeIdentifierLeanBodyMass: 'lean_body_mass',
  HKQuantityTypeIdentifierHeight: 'height',
  HKQuantityTypeIdentifierVO2Max: 'vo2_max',
  HKQuantityTypeIdentifierHeartRateVariabilitySDNN: 'heart_rate_variability_sdnn',
  // Apple computes this natively post-workout (drop in bpm from peak to 1 min
  // of recovery) - no need to derive it from raw continuous heart-rate streams.
  HKQuantityTypeIdentifierHeartRateRecoveryOneMinute: 'heart_rate_recovery',
};

// These two are emitted by HealthKit as many small interval samples per day
// (tens to ~100/day) - not a useful shape for a metabolic estimate, so they
// are summed to one value per calendar day during extraction.
const DAILY_SUM_TYPES = {
  HKQuantityTypeIdentifierBasalEnergyBurned: 'basal_energy_daily',
  HKQuantityTypeIdentifierActiveEnergyBurned: 'active_energy_daily',
};

// Placeholder written instead of the export's real date of birth.
const PLACEHOLDER_BIRTH_DATE = '2000-01-01';

// Source names in an export usually carry the owner's name ("<Name>'s Apple Watch");
// only these generic labels are ever written out.
function genericSource(name) {
  const n = (name ?? '').toLowerCase().replace(/\u00a0/g, ' ');
  if (n.includes('watch')) return 'Apple Watch';
  if (n.includes('iphone')) return 'iPhone';
  if (n === 'health') return 'Health';
  return 'Other app';
}

function attr(line, name) {
  const m = line.match(new RegExp(`${name}="([^"]*)"`));
  return m ? m[1] : null;
}

// "2022-11-13 01:50:48 +0300" -> Date
function parseAppleDate(raw) {
  if (!raw) return null;
  const m = raw.match(/^(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) ([+-]\d{2})(\d{2})$/);
  if (!m) return null;
  return new Date(`${m[1]}T${m[2]}${m[3]}:${m[4]}`);
}

async function main() {
  if (!existsSync(EXPORT_XML)) {
    console.error(`Export not found at ${EXPORT_XML} - nothing to extract.`);
    process.exitCode = 1;
    return;
  }
  mkdirSync(OUT_DIR, { recursive: true });

  const pointSamples = {}; // fileName -> [{value, unit, dateFrom, dateTo, sourceName}]
  for (const fileName of Object.values(QUANTITY_TYPES)) pointSamples[fileName] = [];

  const dailySums = {}; // fileName -> { 'YYYY-MM-DD' -> {sum, unit, sourceName} }
  for (const fileName of Object.values(DAILY_SUM_TYPES)) dailySums[fileName] = {};

  let characteristics = null;
  let lineCount = 0;
  let keptCount = 0;

  const rl = createInterface({ input: createReadStream(EXPORT_XML, { encoding: 'utf8' }), crlfDelay: Infinity });

  for await (const line of rl) {
    lineCount += 1;
    if (lineCount % 1_000_000 === 0) {
      console.error(`... scanned ${lineCount.toLocaleString()} lines`);
    }

    if (line.includes('<Me ')) {
      const sexRaw = attr(line, 'HKCharacteristicTypeIdentifierBiologicalSex');
      characteristics = {
        sex: sexRaw === 'HKBiologicalSexMale' ? 'male' : sexRaw === 'HKBiologicalSexFemale' ? 'female' : null,
        birthDate: PLACEHOLDER_BIRTH_DATE,
      };
      continue;
    }

    if (!line.includes('<Record ')) continue;

    const type = attr(line, 'type');
    if (!type) continue;

    const startDateRaw = attr(line, 'startDate');
    const startDate = parseAppleDate(startDateRaw);
    if (!startDate) continue;
    // Height barely changes in adulthood and is rarely re-logged - keep every
    // reading regardless of date rather than requiring one inside the 2022+
    // window (a real HealthKit query for height would do the same: take the
    // latest ever recorded, not the latest within an arbitrary cutoff).
    if (type !== 'HKQuantityTypeIdentifierHeight' && startDate < CUTOFF) continue;
    const dayKey = startDateRaw.slice(0, 10);

    if (QUANTITY_TYPES[type]) {
      const fileName = QUANTITY_TYPES[type];
      const value = parseFloat(attr(line, 'value'));
      if (Number.isNaN(value)) continue;
      const endDateRaw = attr(line, 'endDate') ?? startDateRaw;
      pointSamples[fileName].push({
        value,
        unit: attr(line, 'unit') ?? '',
        dateFrom: startDate.toISOString(),
        dateTo: (parseAppleDate(endDateRaw) ?? startDate).toISOString(),
        sourceName: genericSource(attr(line, 'sourceName')),
      });
      keptCount += 1;
      continue;
    }

    if (DAILY_SUM_TYPES[type]) {
      const fileName = DAILY_SUM_TYPES[type];
      const value = parseFloat(attr(line, 'value'));
      if (Number.isNaN(value)) continue;
      const bucket = dailySums[fileName];
      if (!bucket[dayKey]) bucket[dayKey] = { sum: 0, unit: attr(line, 'unit') ?? 'kcal' };
      bucket[dayKey].sum += value;
      keptCount += 1;
      continue;
    }
  }

  console.error(`Scanned ${lineCount.toLocaleString()} lines, kept ${keptCount.toLocaleString()} raw records.`);

  // Write point-sample files as-is.
  for (const [fileName, samples] of Object.entries(pointSamples)) {
    samples.sort((a, b) => a.dateFrom.localeCompare(b.dateFrom));
    writeJson(fileName, samples);
  }

  // Write daily-sum files as one HealthSample-shaped entry per day.
  for (const [fileName, byDay] of Object.entries(dailySums)) {
    const days = Object.keys(byDay).sort();
    const samples = days.map((day) => ({
      value: Math.round(byDay[day].sum * 1000) / 1000,
      unit: byDay[day].unit,
      dateFrom: `${day}T00:00:00.000`,
      dateTo: `${day}T23:59:59.000`,
      sourceName: 'Apple Watch',
    }));
    writeJson(fileName, samples);
  }

  writeJson('characteristics', characteristics ?? { sex: null, birthDate: null });

  console.error(`Done. Fixtures written to ${OUT_DIR}`);
}

function writeJson(fileName, data) {
  const path = join(OUT_DIR, `${fileName}.json`);
  writeFileSync(path, JSON.stringify(data));
  console.error(`  wrote ${fileName}.json (${Array.isArray(data) ? data.length : 1} entr${Array.isArray(data) && data.length === 1 ? 'y' : 'ies'})`);
}

main();
