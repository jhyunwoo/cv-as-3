function [x, y, scores, Ih, Iv] = extract_keypoints(image)
%% extract_keypoints
% input:
%   image: colored image. Not grayscale or double yet.
% output:
%   x: n x 1 vector of x (col) locations that survive non-maximum suppression. 
%   y: n x 1 vector of y (row) locations that survive non-maximum suppression.
%   scores: n x 1 vector of R scores of the keypoints correponding to (x,y).
%   Ih: x- (horizontal) gradient. Also appeared as Ix in the slides.
%   Iv: y- (vertical) gradient. Also appeared as Iy in the slides.

% The kernels are provided, but you can try other kernels.
Ih_kernel = [1 0 -1; ...
             2 0 -2; ...
             1 0 -1];
Iv_kernel = Ih_kernel';

%% [10 pts] Part A: Setup (Implement yourself)
k = 0.05; % Harris 식의 경험적 상수
win = 5; % 합산 윈도우 크기
r = floor((win - 1) / 2);

% 컬러를 그레이 스케일로 변환
Igray = rgb2gray(image);

% 이미지를 더블 형태로 변환
I = double(Igray);

% 수평 그래디언트 계산
Ih = imfilter(I, Ih_kernel);
% 수직 그래디언트 계산
Iv = imfilter(I, Iv_kernel);

% 이미지 높이와 너비
[H, W] = size(I);

% Harris R 정수를 저장할 변수 초기화
R = -inf(H, W);

%% [15 pts] Part B: R score matrix (Implement yourself)

for i = (1 + r):(H - r)
    for j = (1 + r):(W-r)
        Ih_win = Ih(i - r:i + r, j - r:j + r); % x방향 그래디언트 패치
        Iv_win = Iv(i - r: i + r, j - r: j+ r); % y방향 그래디언트 패치

        % 2차 통계량 합계 계산
        Sxx = sum(Ih_win(:).^2);
        Syy = sum(Iv_win(:).^2);
        Sxy = sum((Ih_win(:).*Iv_win(:)));

        % 해리스 코너 계산
        M = [Sxx, Sxy; Sxy, Syy];
        R(i, j) = det(M) - k * (trace(M))^2;
    end
end

%% Part C: Thresholding R scores (Provided to you, do not modify)
% Threshold standards is arbitrary, but for this assignment, I set the 
% value of the 1th percentile R as the threshold. So we only keep the
% largest 1% of the R scores (that are not -Inf) and their locations.
R_non_inf = R(~isinf(R));
top_R = sort(R_non_inf(:), 'descend');
R_threshold = top_R(round(length(top_R)*0.01));
R(R < R_threshold) = -Inf;

%% [15 pts] Part D: Non-maximum Suppression (Implement yourself)

R_nms = -inf(H, W); % R 저장 배열 초기화
for i = 2:(H-1) % 1픽셀 경계 제외
    for j = 2: (W-1)
        if isinf(R(i, j)), continue;  % -Inf면 스킵
        end
        patch = R(i-1:i+1, j-1: j+1); % i, j 주변 3x3 패치
        center = R(i, j); % 중심값
        patch(2,2) = -Inf; % 비교에서 중심을 제외함
        if all(center > patch(:)) % 주변 8개보다 모두 클 때
            R_nms(i, j) = center; % 중심을 보존
        end
    end
end

[ys, xs] = find(~isinf(R_nms)); % -Inf가 아닌 위치 인덱스
idx = sub2ind([H, W], ys, xs); % 선형 인덱스 변환
scores = R_nms(idx); % 해당 위치 R 점수 벡터

% 결과
x = xs(:);
y = ys(:);
scores = scores(:);
end
