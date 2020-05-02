clear all
clc
close all

XTrain={};
YTrain={};




%% load female speaker wav samples
cd 'C:\Users\Eric\Desktop\Project\Data\wav_fsew'

filedir = dir('*.wav');           %list the current folder content for .wav file
Y_female = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
FS_female = Y_female;    %pre-allocate FS in memory (edit from @ Werner)

number =length(filedir);

for i = 1:460       %loop through the file names

    %read the .wav file and store them in cell arrays
    [Y_female{1,i}, FS_female{1,i}] = audioread(filedir(i).name);  

end


%% load female speaker lab samples
cd 'C:\Users\Eric\Desktop\Project\Data\lab_fsew'

filedir = dir('*.lab');   %list the current folder content for .wav file

lab_female = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
num_of_phonemes_female=ones(1,length(filedir));
for i = 1:460   %loop through the file names

    %read the .lab file and store them in cell arrays
    [Phonemes,numPhonemes] = convert_LAB_to_Phonemes(filedir(i).name);  
    lab_female{1,i}=Phonemes;
    num_of_phonemes_female(i)=numPhonemes;

end

%% build the training set
for i= 1:460
    Y_female{1,i}=Y_female{1,i}(1:lab_female{1,i}{num_of_phonemes_female(i),2}*16000);
    XTrain=[XTrain,Y_female{1,i}'];
    
    
    label_sequence={};
    for j=1:num_of_phonemes_female(i)
        for k= 1: (lab_female{1,i}{j,2}-lab_female{1,i}{j,1})*16000
            label_sequence=[label_sequence,lab_female{1,i}{j,3}];
        end
    
    end
     if length(label_sequence) > length(Y_female{1,i}')
            label_sequence=label_sequence(1:length(Y_female{1,i}'));
     else
            Y_female{1,i}=Y_female{1,i}(1:length(label_sequence));
            XTrain{i}=Y_female{1,i}';
     end
    state = categorical(label_sequence);
    YTrain{i}=state;
    
    
end
XFemale=XTrain';
YFemale=YTrain';

save XFemale
save YFemale
