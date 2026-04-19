# Politica de confidențialitate

**Ultima actualizare:** 18 aprilie 2026
**Data intrării în vigoare:** 18 aprilie 2026

Această Politică de confidențialitate explică modul în care **Gym Tracker** (denumită în continuare „Aplicația") colectează, utilizează și partajează datele tale cu caracter personal, precum și drepturile pe care le ai. Este redactată pentru a respecta Regulamentul General privind Protecția Datelor al UE („**GDPR**") și Legea nr. 190/2018.

## 1. Cine suntem (operatorul de date)

Operatorul datelor tale cu caracter personal este:

- **Covaciu Andrei** (persoană fizică), stabilit în București, România
- **Email de contact:** covaciuandrei21@gmail.com

Pentru orice întrebare privind această Politică sau datele tale cu caracter personal, ne poți contacta la adresa de mai sus.

## 2. Ce date colectăm

Colectăm următoarele categorii de date cu caracter personal:

### a. Date de cont
- Adresa de email
- Numele afișat (poreclă pe care o alegi)
- O parolă stocată în mod securizat, sub formă de hash (prin Firebase Authentication; noi nu vedem niciodată parola în clar)
- Un identificator unic de utilizator generat de Firebase

### b. Date privind sănătatea (categorie specială — art. 9 GDPR)

Pentru că Aplicația îți permite să înregistrezi antrenamente și suplimente, următoarele date pot dezvălui informații despre activitatea ta fizică și starea ta de bine și sunt tratate ca **date privind sănătatea**:

- Înregistrările de prezență la sală (date și, opțional, notițe)
- Tipurile de antrenament, culorile, pictogramele și durata pe sesiune
- Produsele de suplimente înregistrate (nume, marcă, ingrediente) și porțiile luate zilnic
- Statisticile derivate din cele de mai sus

### c. Preferințe
- Temă (închisă / deschisă)
- Limbă (engleză / română)

### d. Date tehnice
- Timestamp-uri pentru creare cont, ultima autentificare și ultimul email de verificare trimis
- Metadate de la Firebase Authentication (de ex. ora ultimei autentificări)
- Jurnale la nivel de infrastructură păstrate de sub-împuternicitul nostru Google (de ex. adresă IP, tip de dispozitiv) pentru securitate și fiabilitate. Nu avem acces direct la aceste jurnale; acestea sunt procesate de Google pe baza propriilor condiții.
- **Rapoarte de eroare și de blocare a aplicației** colectate de Firebase Crashlytics atunci când Aplicația întâmpină o eroare neașteptată. Rapoartele includ stiva de apeluri, modelul dispozitivului, versiunea sistemului de operare și identificatorul tău Firebase (nu adresa ta de email sau numele afișat), pentru a putea corela raportul cu contul afectat și a diagnostica problema. Crashlytics nu colectează conținutul antrenamentelor, suplimentelor sau mesajelor tale.

În prezent **nu** folosim SDK-uri terțe de analiză sau publicitate. Aplicația nu folosește cookie-uri.

## 3. Scopuri și temeiuri juridice

Prelucrăm datele tale pentru următoarele scopuri:

| Scop | Date utilizate | Temei juridic |
|---|---|---|
| Crearea și menținerea contului, furnizarea funcționalităților esențiale | Date de cont, preferințe | Art. 6 alin. (1) lit. b) GDPR — executarea unui contract |
| Înregistrarea și afișarea antrenamentelor, prezențelor și a aportului de suplimente | Date privind sănătatea | **Art. 9 alin. (2) lit. a) GDPR — consimțământul tău explicit** (colectat prin bifa de la înregistrare) |
| Menținerea securității și funcționării serviciului | Date tehnice | Art. 6 alin. (1) lit. f) GDPR — interes legitim în prevenirea abuzului și asigurarea fiabilității |
| Respectarea obligațiilor legale | După caz | Art. 6 alin. (1) lit. c) GDPR — obligație legală |

Îți poți retrage oricând consimțământul pentru prelucrarea datelor privind sănătatea, ștergându-ți contul din **Setări → Ștergere cont**. Retragerea consimțământului nu afectează legalitatea prelucrărilor efectuate anterior.

## 4. Cui divulgăm datele (sub-împuterniciți)

Divulgăm datele cu caracter personal numai către furnizorii de servicii de care avem nevoie pentru operarea Aplicației. În prezent:

- **Google Ireland Limited / Google LLC** — furnizează Firebase Authentication, Cloud Firestore, Firebase Hosting și Firebase Crashlytics (raportare de erori și blocări). Datele sunt prelucrate în baza [Google Cloud Data Processing Addendum](https://cloud.google.com/terms/data-processing-addendum) și a clauzelor contractuale standard (SCC) ale Google.

**Nu** vindem datele tale cu caracter personal și nu le partajăm cu agenți de publicitate.

## 5. Transferuri internaționale de date

Sub-împuternicitul nostru Google poate prelucra și stoca date pe servere aflate în afara Spațiului Economic European, inclusiv în Statele Unite. Aceste transferuri sunt acoperite de **Clauzele Contractuale Standard** aprobate de Comisia Europeană și de măsurile suplimentare implementate de Google. Poți consulta garanțiile relevante în documentația Google.

## 6. Cât timp păstrăm datele

- **Datele contului și tot conținutul pe care îl creezi** sunt păstrate atât timp cât contul tău există.
- Când îți ștergi contul din **Setări → Ștergere cont**, ștergem datele tale din Firestore (prezențe, antrenamente, înregistrări de suplimente, produse create de tine) și contul tău din Firebase Authentication.
- Unele metadate reziduale (de ex. timestamp-urile de ultimă autentificare din Firebase Authentication) pot persista pentru o scurtă perioadă operațională, de regulă până la 30 de zile, înainte de a fi șterse de Google.
- Putem păstra date minime pentru mai mult timp doar dacă legea ne obligă.

## 7. Drepturile tale

În baza GDPR, ai dreptul la:

- **Acces** la datele cu caracter personal pe care le deținem despre tine;
- **Rectificarea** datelor inexacte sau incomplete (poți edita majoritatea datelor direct din Aplicație);
- **Ștergerea** datelor („dreptul de a fi uitat") — folosește **Setări → Ștergere cont** sau scrie-ne pe email;
- **Restricționarea** sau **opoziția** față de prelucrare, acolo unde se aplică;
- **Portabilitatea** datelor — să le primești într-un format structurat, citibil de un dispozitiv;
- **Retragerea consimțământului** oricând (pentru datele privind sănătatea, art. 9) — echivalentă cu ștergerea contului;
- **A nu fi supus** unor decizii bazate exclusiv pe prelucrare automată (nu folosim așa ceva).

Pentru a-ți exercita oricare drept, scrie-ne la **covaciuandrei21@gmail.com**. Vom răspunde în termen de o lună, conform GDPR.

Ai, de asemenea, dreptul de a depune o plângere la autoritatea de supraveghere din România:

- **ANSPDCP — Autoritatea Națională de Supraveghere a Prelucrării Datelor cu Caracter Personal**
- B-dul G-ral. Gheorghe Magheru nr. 28-30, Sector 1, cod poștal 010336, București, România
- Email: anspdcp@dataprotection.ro
- Website: https://www.dataprotection.ro

## 8. Minori

Aplicația nu este destinată persoanelor sub **16 ani**. Nu colectăm cu bună știință date de la copii sub 16 ani. Dacă afli că un copil ne-a furnizat date, contactează-ne și le vom șterge fără întârziere.

## 9. Securitate

Ne bazăm pe măsuri standard de securitate oferite de Firebase: transport criptat (TLS), Firebase Authentication și reguli de securitate Firestore care restricționează accesul fiecărui utilizator la propriul cont. Niciun sistem nu este perfect sigur, dar facem tot posibilul să îți protejăm datele și vom notifica atât utilizatorii, cât și autoritatea de supraveghere, cu privire la orice incident, în condițiile legii.

## 10. Modificări ale acestei Politici

Putem actualiza această Politică de confidențialitate periodic. Când o facem, vom actualiza data de la „Ultima actualizare" din partea de sus. Dacă modificările sunt semnificative, te vom anunța prin Aplicație înainte de intrarea lor în vigoare.

## 11. Contact

- **Email:** covaciuandrei21@gmail.com
- **Operator:** Covaciu Andrei, București, România
