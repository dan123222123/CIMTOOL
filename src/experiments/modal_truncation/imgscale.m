tmpdir = 'tmp_madness_3/';
wobj = VideoWriter('cc_iss_3.avi'); wobj.FrameRate = 60; open(wobj);
for i=1:600
    fname = strcat(tmpdir,'f',num2str(i)); writeVideo(wobj,im2frame(imread([fname '.jpg'])));
end