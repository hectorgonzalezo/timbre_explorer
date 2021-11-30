for file in *.wav
do
	name=$(echo "$file" | cut -f1 -d'.')
	echo $name
	cp $file ${name}_or.wav
	ffmpeg -ss 00:00:00 -t 00:00:04 -i ${name}_or.wav -af afade=t=out:st=3.50:d=0.5:curve=qua -ar 16000 -y $file
done

