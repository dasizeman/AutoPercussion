// sound file
me.sourceDir() + "snare.wav" => string filename;
if( me.args() ) me.arg(0) => filename;

// Beats per minute
60 => int BPM;
60000::ms / BPM => dur beat;

// Beats per measure
4 => int beatsPerMeasure;

16 => int numMeasures;

// Resolution (smallest time between drum hits)
4 => int RESDIVISOR;
beat / RESDIVISOR => dur resolution;

public class Instrument {
    string m_samplePath;
    float m_probability;
}

(beat * beatsPerMeasure * numMeasures)  => dur totalTime;

Instrument kick;
"kick.wav" => kick.m_samplePath;
0.214 => kick.m_probability;
spork ~ playInstrument(kick, totalTime);

Instrument snare;
"snare.wav" => snare.m_samplePath;
0.107 => snare.m_probability;
spork ~ playInstrument(snare, totalTime);

Instrument hat;
"hat.wav" => hat.m_samplePath;
0.429 => hat.m_probability;
spork ~ playInstrument(hat, totalTime);

totalTime => now;

fun void playInstrument (Instrument inst, dur playTime) {
    now => time start;
    while (now < (start + playTime)) {
        Math.randomf() => float roll;

        if (roll <= inst.m_probability)
            spork ~ playSample(inst.m_samplePath);

        resolution => now;
    }
}

fun float[] rollHits(int numHits) {
    float hits[numHits];

    for (0 => int i; i < numHits; i++) {
        Math.randomf() => hits[i];
    }

    return hits;
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
