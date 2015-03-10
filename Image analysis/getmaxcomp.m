img = imread('MAX_Cl98_954_ko_p2.tif');
stem_sensitivity = 0.9; % higher is more sensitive, must be under 1.
brightness = 0.1; 

imgbw = im2bw(img, brightness);
figure(1);
image(img);

comps = bwconncomp(imgbw);
sizes = cellfun(@numel, comps.PixelIdxList);
[size, idx] = max(sizes);

imgbw(1:comps.ImageSize(1), 1:comps.ImageSize(2)) = 0;
imgbw(comps.PixelIdxList{idx}) = 1;
figure(2);
image(imgbw);
sprintf('Size of the cell (um^2): %f', size*0.22*0.22)



imgbwdark = im2bw(img, 0.5);
erode = floor(sqrt(sum(sum(imgbwdark))) / 8);
imgbwdark = imerode(imgbwdark, strel('disk', erode));
comps = bwconncomp(imgbwdark);
sizesdark = cellfun(@numel, comps.PixelIdxList);
[sizedark, idx] = max(sizesdark);

xs = mod(comps.PixelIdxList{idx}(1), comps.ImageSize(1));
ys = floor(comps.PixelIdxList{idx}(1) / comps.ImageSize(1));

found_stem = 0;
found_dendrite = 0;
i = 1;
last_count = 0;
while found_dendrite == 0
    count = 0;
    for x = max(xs-i, 1):min(xs+i, comps.ImageSize(1))
        for y = max(ys-i, 1):min(ys+i, comps.ImageSize(2))
            count = count + imgbw(x, y);
            imgbw(x, y) = 0;
        end 
    end
    
    count = count / i;
    
    if found_stem == 0 
        if last_count > count * 1.2
            found_stem = 1;
        end
    elseif last_count < count * stem_sensitivity
        found_dendrite = 1;
    end
    
    last_count = count;
    i = i + 1;
    
    if i > 300 
        found_dendrite = 1;
    end
end

hull = bwconvhull(imgbw);
sprintf('Size of spread (um^2): %f', sum(sum(hull))*0.22*0.22)
figure(3);
image(xor(hull,imgbw));