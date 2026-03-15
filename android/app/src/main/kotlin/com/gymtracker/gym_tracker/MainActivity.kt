package com.gymtracker.gym_tracker

import android.content.Context
import android.content.res.Configuration
import android.util.DisplayMetrics
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
	override fun attachBaseContext(newBase: Context?) {
		if (newBase == null) {
			super.attachBaseContext(null)
			return
		}

		val configuration = Configuration(newBase.resources.configuration).apply {
			densityDpi = DisplayMetrics.DENSITY_DEVICE_STABLE
		}

		val fixedDensityContext = newBase.createConfigurationContext(configuration)
		super.attachBaseContext(fixedDensityContext)
	}
}
