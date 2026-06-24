import 'package:flutter/foundation.dart';
// Conditional import helper for JS on Web
import 'dart:js' as js;

class AlarmSoundHelper {
  static bool _isPlaying = false;

  /// Play selected tone using Web Audio API (since user runs on Chrome)
  static void play(String toneName) {
    if (!kIsWeb) {
      debugPrint("Audio playback fallback on native platforms for tone: $toneName");
      return;
    }

    if (_isPlaying) stop();
    _isPlaying = true;

    try {
      if (toneName == 'Retro Synth') {
        js.context.callMethod('eval', ["""
          (function() {
            window.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            window.oscNode = window.audioCtx.createOscillator();
            window.gainNode = window.audioCtx.createGain();
            
            window.oscNode.type = 'sawtooth';
            window.oscNode.frequency.setValueAtTime(150, window.audioCtx.currentTime);
            // Create a retro rising siren effect
            window.oscNode.frequency.linearRampToValueAtTime(800, window.audioCtx.currentTime + 2);
            window.oscNode.loop = true;
            
            window.gainNode.gain.setValueAtTime(0.3, window.audioCtx.currentTime);
            window.oscNode.connect(window.gainNode);
            window.gainNode.connect(window.audioCtx.destination);
            window.oscNode.start();
          })();
        """]);
      } else if (toneName == 'Gentle Morning') {
        js.context.callMethod('eval', ["""
          (function() {
            window.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            window.oscNode = window.audioCtx.createOscillator();
            window.gainNode = window.audioCtx.createGain();
            
            window.oscNode.type = 'triangle';
            window.oscNode.frequency.setValueAtTime(330, window.audioCtx.currentTime); // E4 note
            // Soft pulsating frequency
            window.oscNode.frequency.setValueAtTime(440, window.audioCtx.currentTime + 0.5); // A4 note
            
            window.gainNode.gain.setValueAtTime(0.25, window.audioCtx.currentTime);
            window.oscNode.connect(window.gainNode);
            window.gainNode.connect(window.audioCtx.destination);
            window.oscNode.start();
            
            // Loop melody using interval
            window.melodyInterval = setInterval(function() {
              if (window.oscNode) {
                var notes = [330, 392, 440, 523];
                var randomNote = notes[Math.floor(Math.random() * notes.length)];
                window.oscNode.frequency.setValueAtTime(randomNote, window.audioCtx.currentTime);
              }
            }, 600);
          })();
        """]);
      } else if (toneName == 'Digital Radar') {
        js.context.callMethod('eval', ["""
          (function() {
            window.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            window.oscNode = window.audioCtx.createOscillator();
            window.gainNode = window.audioCtx.createGain();
            
            window.oscNode.type = 'square';
            window.oscNode.frequency.setValueAtTime(880, window.audioCtx.currentTime);
            
            window.gainNode.gain.setValueAtTime(0.15, window.audioCtx.currentTime);
            window.oscNode.connect(window.gainNode);
            window.gainNode.connect(window.audioCtx.destination);
            window.oscNode.start();
            
            window.melodyInterval = setInterval(function() {
              if (window.oscNode) {
                // Alternating high frequencies
                var freq = window.oscNode.frequency.value === 880 ? 1200 : 880;
                window.oscNode.frequency.setValueAtTime(freq, window.audioCtx.currentTime);
              }
            }, 250);
          })();
        """]);
      } else {
        // Default: Radial Beep
        js.context.callMethod('eval', ["""
          (function() {
            window.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            window.oscNode = window.audioCtx.createOscillator();
            window.gainNode = window.audioCtx.createGain();
            
            window.oscNode.type = 'sine';
            window.oscNode.frequency.setValueAtTime(520, window.audioCtx.currentTime);
            
            window.gainNode.gain.setValueAtTime(0.3, window.audioCtx.currentTime);
            window.oscNode.connect(window.gainNode);
            window.gainNode.connect(window.audioCtx.destination);
            window.oscNode.start();
            
            window.melodyInterval = setInterval(function() {
              if (window.gainNode) {
                // Pulsate volume to simulate a beep-beep-beep
                var val = window.gainNode.gain.value === 0.3 ? 0.01 : 0.3;
                window.gainNode.gain.setValueAtTime(val, window.audioCtx.currentTime);
              }
            }, 400);
          })();
        """]);
      }
    } catch (e) {
      debugPrint("Web Audio API not supported or user interaction required: $e");
    }
  }

  static void stop() {
    if (!kIsWeb) return;
    _isPlaying = false;

    try {
      js.context.callMethod('eval', ["""
        (function() {
          if (window.melodyInterval) {
            clearInterval(window.melodyInterval);
            window.melodyInterval = null;
          }
          if (window.oscNode) {
            try { window.oscNode.stop(); } catch(e) {}
            window.oscNode = null;
          }
          if (window.audioCtx) {
            try { window.audioCtx.close(); } catch(e) {}
            window.audioCtx = null;
          }
        })();
      """]);
    } catch (e) {
      debugPrint("Error stopping oscillator: $e");
    }
  }
}
