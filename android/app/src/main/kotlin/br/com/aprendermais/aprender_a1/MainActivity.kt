package br.com.aprendermais.aprender_a1

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.*
import android.hardware.*
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.*
import android.provider.MediaStore
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.math.roundToInt
import kotlin.math.sqrt

/** Recursos Android. As telas e as regras dos jogos continuam em Dart. */
class MainActivity : FlutterActivity(), SensorEventListener {
    private var sink: EventChannel.EventSink? = null
    private lateinit var sensors: SensorManager
    private var receiverRegistered = false
    private var lastMotion = 0L
    private var lastShake = 0L
    private var photoResult: MethodChannel.Result? = null
    private var voice: MediaPlayer? = null
    private var effect: MediaPlayer? = null
    private var voiceResult: MethodChannel.Result? = null
    private var effectResult: MethodChannel.Result? = null
    private var headsetPresent = false
    private val audioChanges = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>) { checkWiredHeadset() }
        override fun onAudioDevicesRemoved(removedDevices: Array<out AudioDeviceInfo>) { checkWiredHeadset() }
    }
    private fun isWiredOutput(device: AudioDeviceInfo): Boolean = device.isSink &&
        device.type in listOf(AudioDeviceInfo.TYPE_WIRED_HEADSET,
            AudioDeviceInfo.TYPE_WIRED_HEADPHONES, AudioDeviceInfo.TYPE_USB_HEADSET)
    private fun checkWiredHeadset() {
        val audio = getSystemService(AUDIO_SERVICE) as AudioManager
        reportHeadset(audio.getDevices(AudioManager.GET_DEVICES_OUTPUTS).any { isWiredOutput(it) })
    }
    private fun reportHeadset(connected: Boolean) {
        val justConnected = connected && !headsetPresent
        headsetPresent = connected
        if (!justConnected) return
        val audio = getSystemService(AUDIO_SERVICE) as AudioManager
        val half = (audio.getStreamMaxVolume(AudioManager.STREAM_MUSIC) * .5).roundToInt()
        audio.setStreamVolume(AudioManager.STREAM_MUSIC, half, 0)
        sink?.success(mapOf("type" to "headset"))
    }


    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                Intent.ACTION_BATTERY_CHANGED -> sink?.success(mapOf(
                    "type" to "battery", "level" to batteryLevel(intent)))
                Intent.ACTION_HEADSET_PLUG -> {
                    if (!isInitialStickyBroadcast) reportHeadset(intent.getIntExtra("state", 0) == 1)
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sensors = getSystemService(SENSOR_SERVICE) as SensorManager
        val audio = getSystemService(AUDIO_SERVICE) as AudioManager
        headsetPresent = audio.getDevices(AudioManager.GET_DEVICES_OUTPUTS).any { isWiredOutput(it) }
        audio.registerAudioDeviceCallback(audioChanges, Handler(Looper.getMainLooper()))
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "aprender_a1/events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) { sink = events }
                override fun onCancel(arguments: Any?) { sink = null }
            })
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aprender_a1/device")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "snapshot" -> result.success(snapshot())
                        "scores" -> result.success(scoreValues())
                        "saveScore" -> {
                            val game = call.argument<String>("game")
                            val score = call.argument<Int>("score") ?: 0
                            require(game in listOf("quiz", "genius", "memo") && score >= 0)
                            check(getSharedPreferences("a1_scores", MODE_PRIVATE).edit()
                                .putInt(game, score).commit()) { "Falha ao gravar pontuacao" }
                            ScoresWidget.updateAll(this)
                            result.success(null)
                        }
                        "playSound" -> playSound(
                            call.argument<String>("asset") ?: "",
                            call.argument<Boolean>("effect") ?: false, result)
                        "stopAudio" -> {
                            finishSound(false, false); finishSound(true, false)
                            result.success(null)
                        }
                        "vibrate" -> {
                            val vibrator = if (Build.VERSION.SDK_INT >= 31)
                                (getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager).defaultVibrator
                                else @Suppress("DEPRECATION") (getSystemService(VIBRATOR_SERVICE) as Vibrator)
                            if (Build.VERSION.SDK_INT >= 26)
                                vibrator.vibrate(VibrationEffect.createOneShot(180, VibrationEffect.DEFAULT_AMPLITUDE))
                            else @Suppress("DEPRECATION") vibrator.vibrate(180)
                            result.success(null)
                        }
                        "pickPhotos" -> pickPhotos(result)
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("ANDROID_ERROR", error.message, null)
                }
            }
    }

    private fun batteryLevel(intent: Intent?): Int {
        if (intent == null) return -1
        val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        return if (scale > 0 && level >= 0) level * 100 / scale else -1
    }

    private fun snapshot(): Map<String, Any> {
        val battery = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val connectivity = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        val capabilities = connectivity.getNetworkCapabilities(connectivity.activeNetwork)
        val connected = capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) == true &&
            capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
        return mapOf(
            "battery" to batteryLevel(battery),
            "powerSave" to (getSystemService(POWER_SERVICE) as PowerManager).isPowerSaveMode,
            "connected" to connected,
            "accelerometer" to (sensors.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) != null))
    }

    private fun scoreValues(): Map<String, Int> {
        val prefs = getSharedPreferences("a1_scores", MODE_PRIVATE)
        return listOf("quiz", "genius", "memo").associateWith { prefs.getInt(it, 0) }
    }

    private fun finishSound(isEffect: Boolean, completed: Boolean) {
        val player = if (isEffect) effect else voice
        val callback = if (isEffect) effectResult else voiceResult
        if (isEffect) { effect = null; effectResult = null }
        else { voice = null; voiceResult = null }
        player?.release()
        callback?.success(completed)
    }

    private fun playSound(asset: String, isEffect: Boolean, result: MethodChannel.Result) {
        require(asset.startsWith("assets/audio/") && !asset.contains(".."))
        finishSound(isEffect, false)
        val player = MediaPlayer()
        if (isEffect) { effect = player; effectResult = result }
        else { voice = player; voiceResult = result }
        try {
            player.setAudioAttributes(AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(if (isEffect) AudioAttributes.CONTENT_TYPE_SONIFICATION
                    else AudioAttributes.CONTENT_TYPE_SPEECH).build())
            val key = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(asset)
            assets.openFd(key).use { descriptor ->
                player.setDataSource(descriptor.fileDescriptor, descriptor.startOffset, descriptor.length)
            }
            player.setOnPreparedListener { it.start() }
            player.setOnCompletionListener { finishSound(isEffect, true) }
            player.setOnErrorListener { _, _, _ -> finishSound(isEffect, false); true }
            player.prepareAsync()
        } catch (error: Exception) {
            if (isEffect) effectResult = null else voiceResult = null
            finishSound(isEffect, false)
            result.error("AUDIO_ERROR", error.message, null)
        }
    }

    private fun pickPhotos(result: MethodChannel.Result) {
        if (photoResult != null) { result.error("PICKER_BUSY", "A galeria ja esta aberta.", null); return }
        photoResult = result
        val intent = if (Build.VERSION.SDK_INT >= 33) Intent(MediaStore.ACTION_PICK_IMAGES).apply {
            type = "image/*"
            putExtra(MediaStore.EXTRA_PICK_IMAGES_MAX, 4)
        } else Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "image/*"
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        }
        try { startActivityForResult(intent, 2044) }
        catch (error: Exception) {
            photoResult = null
            result.error("GALLERY_ERROR", error.message, null)
        }
    }

    @Deprecated("Usado para integrar o seletor de fotos sem dependencias externas")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 2044) return
        val callback = photoResult ?: return
        photoResult = null
        if (resultCode != Activity.RESULT_OK) { callback.success(emptyList<String>()); return }
        val uris = data?.clipData?.let { clip -> (0 until clip.itemCount).map { clip.getItemAt(it).uri } }
            ?: listOfNotNull(data?.data)
        if (uris.size != 4) {
            callback.error("PHOTO_COUNT", "Selecione exatamente quatro fotos.", null); return
        }
        try {
            val selectionId = System.currentTimeMillis()
            val paths = uris.mapIndexed { index, uri ->
                val file = File(cacheDir, "memocheck_${selectionId}_$index.jpg")
                contentResolver.openInputStream(uri).use { input ->
                    requireNotNull(input) { "Nao foi possivel ler uma foto" }
                    file.outputStream().use { output -> input.copyTo(output) }
                }
                file.absolutePath
            }
            callback.success(paths)
        } catch (error: Exception) { callback.error("PHOTO_READ", error.message, null) }
    }

    override fun onResume() {
        super.onResume()
        if (!::sensors.isInitialized) return
        sensors.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)?.let {
            sensors.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME)
        }
        if (!receiverRegistered) {
            val filter = IntentFilter().apply {
                addAction(Intent.ACTION_BATTERY_CHANGED)
                addAction(Intent.ACTION_HEADSET_PLUG)
            }
            if (Build.VERSION.SDK_INT >= 33) registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            else @Suppress("DEPRECATION") registerReceiver(receiver, filter)
            receiverRegistered = true
        }
    }

    override fun onPause() {
        if (::sensors.isInitialized) sensors.unregisterListener(this)
        super.onPause()
    }

    override fun onDestroy() {
        if (receiverRegistered) { unregisterReceiver(receiver); receiverRegistered = false }
        (getSystemService(AUDIO_SERVICE) as AudioManager).unregisterAudioDeviceCallback(audioChanges)
        finishSound(false, false); finishSound(true, false)
        photoResult?.error("ACTIVITY_CLOSED", "A tela foi fechada.", null)
        photoResult = null; sink = null
        super.onDestroy()
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_ACCELEROMETER) return
        val now = SystemClock.elapsedRealtime()
        val x = event.values[0].toDouble()
        val y = event.values[1].toDouble()
        val z = event.values[2].toDouble()
        if (now - lastMotion >= 80) {
            lastMotion = now
            sink?.success(mapOf("type" to "motion", "x" to x, "y" to y, "z" to z))
        }
        if (sqrt(x*x + y*y + z*z) > 19.5 && now - lastShake > 1000) {
            lastShake = now
            sink?.success(mapOf("type" to "shake"))
        }
    }
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}

