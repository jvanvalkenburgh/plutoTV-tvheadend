#!/bin/bash
url=$1
/usr/local/bin/streamlink --stdout --quiet --twitch-disable-hosting \
    --ringbuffer-size 64M --hds-segment-threads 2 --hls-segment-attempts 5 \
    --hls-segment-timeout 5 --hls-timeout 100000000 --hls-live-restart $url best | ffmpeg -loglevel fatal -err_detect ignore_err \
    -f mpegts -i - \
    -c:v copy -tune zerolatency -pix_fmt yuv420p -force_key_frames \"expr:gte\(t,n_forced*2\)\" \
    -c:a aac -copyts -qscale:s 2 -b:a 256k -ac 2 -af aresample=async=1 -adrift_threshold 0.1 \
    -f mpegts pipe:1

