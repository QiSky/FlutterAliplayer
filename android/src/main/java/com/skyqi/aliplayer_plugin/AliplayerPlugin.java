package com.skyqi.aliplayer_plugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.graphics.drawable.Drawable;
import android.view.Surface;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.player.AliPlayer;
import com.aliyun.player.AliPlayerFactory;
import com.aliyun.player.IPlayer;
import com.aliyun.player.nativeclass.CacheConfig;
import com.aliyun.player.source.UrlSource;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.transition.Transition;

import io.flutter.Log;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.view.TextureRegistry;

public class AliplayerPlugin implements EventChannel.StreamHandler, MethodChannel.MethodCallHandler, FlutterPlugin {

    MethodChannel mMethodChannel;

    EventChannel mEventChannel;

    EventChannel.EventSink mEventSink;

    public static final String METHOD_CHANNEL = "video_player_method";

    public static final String STREAM_CHANNEL = "video_player_stream";

    public static final String START = "start";

    public static final String STOP = "stop";

    public static final String RELEASE = "release";

    public static final String INIT = "init";

    public static final String PAUSE = "pause";
    private TextureRegistry.SurfaceTextureEntry surfaceTextureEntry;

    private FlutterPlugin.FlutterPluginBinding binding;

    private Surface surface;

    private SurfaceTexture surfaceTexture;

    private AliPlayer player;

    private Context mContext;

    public void pluginInit(Context context, FlutterEngine flutterEngine) {
        this.mContext = context;
        mMethodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL);
        mMethodChannel.setMethodCallHandler(this);

        mEventChannel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), STREAM_CHANNEL);
        mEventChannel.setStreamHandler(this);

//        PlatformViewRegistry registry = flutterEngine.getPlatformViewsController().getRegistry();
//        registry.registerViewFactory("aliplayer_view", new AliVideoViewFactory(flutterEngine.getDartExecutor().getBinaryMessenger()));

    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        this.mEventSink = null;
    }

    private CacheConfig initCache() {
        CacheConfig cacheConfig = new CacheConfig();
        cacheConfig.mEnable = true;
        cacheConfig.mMaxDurationS = 100;
        cacheConfig.mDir = mContext.getCacheDir().getAbsolutePath();
        cacheConfig.mMaxSizeMB = 200;
        return cacheConfig;
    }

    private void initPlayer(String mute, String autoplay) {
        if (player != null) {
            player.setAutoPlay(false);
            player.setLoop(true);
            player.setMute(Boolean.parseBoolean(mute));
            player.setAutoPlay(Boolean.parseBoolean(autoplay));
            player.setScaleMode(IPlayer.ScaleMode.SCALE_ASPECT_FILL);
            player.setCacheConfig(initCache());
            player.setOnRenderingStartListener(new IPlayer.OnRenderingStartListener() {
                @Override
                public void onRenderingStart() {
                    if (mEventSink != null) {
                        mEventSink.success("render");
                    }
                }
            });
            player.setOnCompletionListener(new IPlayer.OnCompletionListener() {
                @Override
                public void onCompletion() {

                }
            });
        }
    }

    private void setDataSource(String url) {
        UrlSource urlSource = new UrlSource();
        urlSource.setUri(url);
        player.setDataSource(urlSource);
        player.prepare();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case INIT:
                if (player == null) {
                    player = AliPlayerFactory.createAliPlayer(mContext);
                    initPlayer(call.argument("mute").toString(), call.argument("autoplay").toString());
                    if (call.argument("url") != null && !"".equals(call.argument("url").toString())) {
                        setDataSource(call.argument("url").toString());
                    }
                    if (binding != null)
                        surfaceTextureEntry = binding.getTextureRegistry().createSurfaceTexture();
                    if (surfaceTextureEntry != null) {
                        surfaceTexture = surfaceTextureEntry.surfaceTexture();
                        surface = new Surface(surfaceTexture);
                        player.setSurface(surface);
                    }
                    if (surfaceTextureEntry != null)
                        result.success(surfaceTextureEntry.id());
                    else
                        result.success(-1000);
                }
                break;
            case START:
                if (player != null) {
                    if (call.argument("url") != null && !"".equals(call.argument("url").toString()))
                        setDataSource(call.argument("url").toString());
                    if (call.argument("width") != null || call.argument("height") != null) {
                        surfaceTexture.setDefaultBufferSize(
                                (int) Math.floor(Double.valueOf(call.argument("width").toString())),
                                (int) Math.floor(Double.valueOf(call.argument("height").toString()))
                        );
                    }
                }
                player.start();
                break;
            case PAUSE:
                if (player != null) {
                    player.pause();
                }
                break;
            case RELEASE:
                if (player != null) {
                    player.release();
                }
                break;
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.binding = binding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}

