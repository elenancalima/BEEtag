function v = expandInts(boundsOrList)
% If length==2, treat as inclusive bounds (ascending or descending).
% Otherwise treat as explicit values. Coerce to row of unique integers.
    b = boundsOrList(:).';
    if numel(b) == 2
        a = round(b(1)); z = round(b(2));
        if a <= z
            v = a:z;
        else
            v = a:-1:z;
        end
    else
        v = unique(round(b), 'stable');
    end
end