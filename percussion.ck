// Beats per minute
110 => int BPM;
60000::ms / BPM => dur beat;

// Beats per measure
4 => int beatsPerMeasure;

// Measures to probablistically generate (this length will be looped)
2 => int numMeasures;


// Resolution (smallest time between drum hits)
4 => int RESDIVISOR;
beat / RESDIVISOR => dur resolution;

// Sparsity (chance of nothing hitting)
.25 => float sparsity;



public class Instrument {
    string m_name;
    string m_samplePath;
    float m_probability;
    int m_weight;
}

(RESDIVISOR * beatsPerMeasure * numMeasures)  => int totalHits;
(totalHits * resolution) => dur totalTime;

float hits[totalHits];
Instrument instruments[3];

rollHits(hits);

Instrument kick;
"KICK" => kick.m_name;
"kick.wav" => kick.m_samplePath;
0.214 => kick.m_probability;
kick @=> instruments[0];

Instrument snare;
"SNARE" => snare.m_name;
"snare.wav" => snare.m_samplePath;
0.107 => snare.m_probability;
snare @=> instruments[1];

Instrument hat;
"HAT" => hat.m_name;
"hat.wav" => hat.m_samplePath;
0.429 => hat.m_probability;
hat @=> instruments[2];

while (true) {

    for (0 => int i; i < 3; i++) {
        spork ~ playInstrument(instruments[i], hits);
    }

    <<< "~~~~~~~~~~~~~~~~~~~~~~~~~~", "" >>>;
    totalTime => now;
}

fun void playInstrument (Instrument inst, float hits[]) {
    for (0 => int i; i < hits.cap(); i++) {
        hits[i] => float roll;

        if (roll <= inst.m_probability) {
            spork ~ playSample(inst.m_samplePath);
            <<< "[", roll, "]" , inst.m_name >>>;
        }
        else {
            <<< "[", roll, "] --" >>>;
        }

        resolution => now;
    }
    // Give some time for the last sample to finish playing before dying (hack)
    500::ms => now;
}

fun void rollHits(float hits[]) {

    for (0 => int i; i < hits.cap(); i++) {
        Math.randomf() => hits[i];
    }
}

fun void computeProbabilities(Instrument instruments[]) {
    0 => int divisor;

    for (0 => int i; i < instruments.cap(); i++) {
        divisor + instruments[i].m_weight => divisor;
    }

    for (0 => int i; i < instruments.cap(); i++) {
        (1 - sparsity) * (instruments[i].m_weight / divisor) =>
            instruments[i].m_probability;
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
