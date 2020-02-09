clear all
clc
close all




%% parametres

fy=400; % the number of training male speaker samples
my=400; % the number of training female speaker samples
y=[];
Fs=[];






%% load female speaker wav samples
cd 'C:\Users\Eric\Desktop\Project\Data\wav_fsew'

filedir = dir('*.wav');           %list the current folder content for .wav file
Y_female = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
FS_female = Y_female;                           %pre-allocate FS in memory (edit from @ Werner)
for i = 1:length(filedir)     %loop through the file names

    %read the .wav file and store them in cell arrays
    [Y_female{1,i}, FS_female{1,i}] = audioread(filedir(i).name);  

end

%% load male speaker wav samples
cd 'C:\Users\Eric\Desktop\Project\Data\wav_msak'

filedir = dir('*.wav');           %list the current folder content for .wav file
Y_male = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
FS_male = Y_male;                           %pre-allocate FS in memory (edit from @ Werner)
for i = 1:length(filedir)        %loop through the file names

    %read the .wav file and store them in cell arrays
    [Y_male{1,i}, FS_male{1,i}] = audioread(filedir(i).name);  

end
sound(Y_male{1,1}, FS_male{1,1})



%% load female speaker lab samples
cd 'C:\Users\Eric\Desktop\Project\Data\lab_fsew'

filedir = dir('*.lab');   %list the current folder content for .wav file

lab_female = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
num_of_phonemes_female=ones(1,length(filedir));
for i = 1:length(filedir)   %loop through the file names

    %read the .lab file and store them in cell arrays
    [Phonemes,numPhonemes] = convert_LAB_to_Phonemes(filedir(i).name);  
    lab_female{1,i}=Phonemes;
    num_of_phonemes_female(i)=numPhonemes;

end

%% load male speaker lab samples
cd 'C:\Users\Eric\Desktop\Project\Data\lab_msak'

filedir = dir('*.lab');   %list the current folder content for .wav file

lab_male = cell(1,length(filedir));      %pre-allocate Y in memory (edit from @ Werner)
number_of_phonemes_male=ones(1,length(filedir));
for i = 1:length(filedir)     %loop through the file names

    %read the .lab file and store them in cell arrays
    [Phonemes,numPhonemes] = convert_LAB_to_Phonemes(filedir(i).name);  
    lab_male{1,i}=Phonemes;
    num_of_phonemes_male(i)=numPhonemes;

end

%% segmentation of the female wav plot of samples
phoneme_list=[{'test'}];
cd 'C:\Users\Eric\Desktop\Project\Data\combination'
flag=1;
for i = 1:400

    for j=1:num_of_phonemes_female(i)-1
        figure
        plot(Y_female{1,i}(round(lab_female{1,i}{j,1}*16000+1):round(lab_female{1,i}{j+1,2}*16000)) ,'k');
        axis off
        name1=lab_female{1,i}{j,3};
        name2=lab_female{1,i}{j+1,3};
        c='+';
        name=[name1 c name2];
        cell={name};
        c=ismember(cell,phoneme_list);
   
        if c==0
            phoneme_list=[phoneme_list,cell];
            mkdir(name)
            cd(name)
        else
            cd(name)
        end
        flag=flag+1;
        saveas(gcf,[num2str(flag),'.jpg']);
        close all
        cd 'C:\Users\Eric\Desktop\Project\Data\combination'
        
    end

end
dda=66666

%% segmentation of the male wav plot of samples
phoneme_list=[{'test'}];
cd 'C:\Users\Eric\Desktop\Project\Data\combination'
for i = 1:400

    for j=1:num_of_phonemes_male(i)-1
        figure
        plot(Y_male{1,i}(round(lab_male{1,i}{j,1}*16000+1):round(lab_male{1,i}{j+1,2}*16000)) ,'k');
        axis off
        name1=lab_male{1,i}{j,3};
        name2=lab_male{1,i}{j+1,3};
        c='+';
        name=[name1 c name2];
        cd(name)
        flag=flag+1;
        saveas(gcf,[num2str(flag),'.jpg']);
        close all
        cd 'C:\Users\Eric\Desktop\Project\Data\combination'
        
    end

end

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
