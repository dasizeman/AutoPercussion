// sound file
me.sourceDir() + "snare.wav" => string filename;
if( me.args() ) me.arg(0) => filename;

// Beats per minute
120 => int BPM;
60000::ms / BPM => dur beat;

// Beats per measure
4 => int beatsPerMeasure;

// Resolution (smallest time between drum hits)
2 => int RESDIVISOR;
beat / RESDIVISOR => dur resolution;

spork ~ kick();
resolution => now;
spork ~ hat();
resolution => now;
spork ~ snare();


while (true)
    1::second => now;

fun void kick() {
    while (true) {
        spork ~ playSample("kick.wav");
        2 * resolution => now;
    }
}

fun void hat() {
    while (true) {
        spork ~ playSample("hat.wav");
        resolution => now;
    }
}

fun void snare() {
    while(true) {
        spork ~ playSample("snare.wav");
        4 * resolution => now;
    }
}

fun void playSample (string path) {
    SndBuf buf => dac;
    path => buf.read;

    buf.pos() => int position;
    buf.samples() => int samples;
    while (position < samples) {
        position + 1 => position;
        1::ms => now;
    }
}
