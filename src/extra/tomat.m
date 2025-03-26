[Db,Ds] = test_allpass_mploewner(10);
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));
save('matsucks.mat')