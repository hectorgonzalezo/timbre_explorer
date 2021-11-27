gdown --id 1zreOkpGWQ9V7rNqKJ_aBn6uy9KZQwHPo
gdown --id 1F2DLM0rh5Ft0APh3asBse4g29unjlAop
gdown --id 1zz46NTOXwrZJY1TwjlC6mPyQMfqrz7lQ


ffmpeg -ss 00:00:00 -t 00:00:03 -i 248881__mtg__clarinet-g3-bad-attack-multiphonic.wav -af afade=t=out:st=2:d=1 -ar 16000 -y clarinet.wav
ffmpeg -i 39153__jobro__piano-ff-006.wav -ar 16000 -y piano.wav
ffmpeg -ss 00:00:00 -t 00:00:03 -i 448345__anthousai__marbles-15cm-ceramic-bowl-swirling-marbles-around-bowl-1-13mm-marble.wav -af afade=t=out:st=2:d=1 -ar 16000 -y marbles.wav



#gsutil -q -m cp -R gs://download.magenta.tensorflow.org/models/nsynth/wavenet-ckpt.tar .
#gsutil -q -m cp -R gs://download.magenta.tensorflow.org/models/nsynth/wavenet-voice-ckpt.tar.gz .
#tar -xvf wavenet-ckpt.tar > /dev/null
#tar -xvf wavenet-voice-ckpt.tar.gz > /dev/null

#mkdir encodings 
#mkdir output
