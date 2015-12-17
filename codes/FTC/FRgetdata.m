
function [DataList] = FRgetdata(listname, database_dir)
%
% function [DataList] = FRgetdata(listname, database_dir)
% FRgetdata:
%   get data structure from specified datalist for Face Recognition
% input:
%   listname        string      list file name
%   database_dir    string      database location dir
% output:
%   DataList        struct      output data structure
%
% DataList field  (suppose n faces image)
%   type:   n * 1  cell     dataset name which each face belongs to
%   id:     n * 4  double   [person-id  session-id  face-id  nouse-id] for each face
%   name:   n * 1  cell     image filename of each face
%   feat:   n * 14 double   feature values of each face (see TA's slide for details)
%

temp = importdata(listname);

% save feature
DataList.type = temp.textdata(:, 1);
DataList.feat = temp.data;
DataList.name = temp.textdata(:, 7);
t = temp.textdata(:, 2:5);

n_data = size(temp.data, 1);
DataList.id = [];
for i = 1 : n_data
    DataList.name{i, 1} = [database_dir '/' DataList.name{i, 1}];
    DataList.id 		= [DataList.id; str2num(t{i, 1}), str2num(t{i, 2}), ...
							str2num(t{i, 3}), str2num(t{i, 4})];
end
