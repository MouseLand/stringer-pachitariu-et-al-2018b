load('stimuli_class_assignment')
assert(max(class_assignment) == length(class_names)-1)
class_assignment(class_assignment==12)=2;
class_assignment(class_assignment==13)=0;
class_assignment(class_assignment==14)=0;
class_assignment(class_assignment==15)=0;
class_names = class_names(1:12);
assert(max(class_assignment) == length(class_names)-1)
save('stimuli_class_assignment_confident')
for i=1:length(class_names)-1; fprintf('%d %s\n', length(find(class_assignment==i)), class_names{i+1}); end