
ffmpeg -ss 00:00:00 -t 00:00:03.50 -i bass_a.wav -af afade=t=out:st=2.50:d=1:curve=qua -ar 16000 -y bass.wav
ffmpeg -ss 00:00:00 -t 00:00:03.50 -i oboe_b.wav -af afade=t=out:st=3.30:d=0.5:curve=qua -ar 16000 -y oboe.wav
ffmpeg -ss 00:00:00 -t 00:00:03.50 -i flute_c.wav -af afade=t=out:st=2.50:d=1:curve=qua -ar 16000 -y flute.wav



#gsutil -q -m cp -R gs://download.magenta.tensorflow.org/models/nsynth/wavenet-ckpt.tar .
#gsutil -q -m cp -R gs://download.magenta.tensorflow.org/models/nsynth/wavenet-voice-ckpt.tar.gz .
#tar -xvf wavenet-ckpt.tar > /dev/null
#tar -xvf wavenet-voice-ckpt.tar.gz > /dev/null

#mkdir encodings 
#mkdir output
