clear all
clear all
clc
close all

XTrain={};
YTrain={};




%% load male speaker wav samples
cd 'C:\Users\Eric\Desktop\Project\Data\wav_msak'

filedir = dir('*.wav');           %list the current folder content for .wav file
Y_male = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
FS_male = Y_male;    %pre-allocate FS in memory (edit from @ Werner)

number =length(filedir);

for i = 1:460       %loop through the file names

    %read the .wav file and store them in cell arrays
    [Y_male{1,i}, FS_male{1,i}] = audioread(filedir(i).name);  

end


%% load male speaker lab samples
cd 'C:\Users\Eric\Desktop\Project\Data\lab_msak'

filedir = dir('*.lab');   %list the current folder content for .wav file

lab_male = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
num_of_phonemes_male=ones(1,length(filedir));
for i = 1:460   %loop through the file names

    %read the .lab file and store them in cell arrays
    [Phonemes,numPhonemes] = convert_LAB_to_Phonemes(filedir(i).name);  
    lab_male{1,i}=Phonemes;
    num_of_phonemes_male(i)=numPhonemes;

end

%% build the training set
for i= 1:460
    Y_male{1,i}=Y_male{1,i}(1:lab_male{1,i}{num_of_phonemes_male(i),2}*16000);
    XTrain=[XTrain,Y_male{1,i}'];
    
    
    label_sequence={};
    for j=1:num_of_phonemes_male(i)
        for k= 1: (lab_male{1,i}{j,2}-lab_male{1,i}{j,1})*16000
            label_sequence=[label_sequence,lab_male{1,i}{j,3}];
        end
    
    end
     if length(label_sequence) > length(Y_male{1,i}')
            label_sequence=label_sequence(1:length(Y_male{1,i}'));
     else
            Y_male{1,i}=Y_male{1,i}(1:length(label_sequence));
            XTrain{i}=Y_male{1,i}';
     end
    state = categorical(label_sequence);
    YTrain{i}=state;
    
    
end
XMale=XTrain';
YMale=YTrain';

save XMale
save YMale



%% convert lab to matlab cell
function [Phonemes,numPhonemes] = convert_LAB_to_Phonemes(LAB)

% Input may be a cell with the labelled phonemes or just the file from which these
% must be read
if ~isa(LAB,'cell')
    LAB = importdata(LAB,' ');
end
    %% Interpret Labelled Phonemes
    % Read the numLines    
    numPhonemes             = size(LAB,1);
    Phonemes{numPhonemes,3}     = '';
    for k=1:numPhonemes
        % Each line is a {start end phoneme}
        currLine            = LAB{k};
        placesSpace         = strfind(currLine,' ');
        Phonemes{k,1}           = str2double(currLine(1:placesSpace(1)-1));
        Phonemes{k,2}           = str2double(currLine(placesSpace(1)+1:placesSpace(2)-1));
        Phonemes{k,3}           = (currLine(placesSpace(2)+1:end));
    end
end