package com.skyqi.aliplayer_plugin_example

import com.skyqi.aliplayer_plugin.AliplayerPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        (flutterEngine.plugins.get(AliplayerPlugin::class.java) as AliplayerPlugin).apply {
            pluginInit(this@MainActivity, flutterEngine)
        }
    }
}
