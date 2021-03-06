% Numerical experiment 51 x 2 bands (det.) + coord. on the Pavia center data set [2]
% for the Allen-Cahn multiclass classification scheme [1, Algorithm 6.1]
% using the power mean Laplacian [3]
% using the NFFT-based fast summation [4] for the eigeninformation computations [5]
%
% We employ feature grouping [1, Section 7] in order to decompose the 
% 104-dimensional feature space (102 hyperspectral bands + XY pixel coordinates) 
% into a 52-layer multilayer graph, where the 51 layers of spectral bands are
% chosen as (1, 52), (2, 53), ... , (51, 102) and consider the corresponding
% power mean Laplacian [3]. 
% 
% [1] Kai Bergermann, Martin Stoll, and Toni Volkmer. Semi-supervised Learning for Multilayer Graphs Using Diffuse Interface Methods and Fast Matrix Vector Products. Submitted, 2020. 
% [2] A. Plaza, J. A. Benediktsson, J. W. Boardman, J. Brazile, L. Bruzzone, G. Camps-Valls, J. Chanussot, M. Fauvel, P. Gamba, A. Gualtieri, et al. Recent advances in techniques for hyperspectral image processing. Remote sensing of environment, 113 (2009), pp. S110-S122.
% [3] Pedro Mercado, Antoine Gautier, Francesco Tudisco, and Matthias Hein. The power mean Laplacian for multilayer graph clustering. In Proceedings of the Twenty-First International Conference on Artificial Intelligence and Statistics, volume 84 of Proceedings of Machine Learning Research, pages 1828-1838, 2018.
% [4] Daniel Potts, Gabriele Steidl, and Arthur Nieslony. Fast convolution with radial kernels at nonequispaced knots. Numerische Mathematik 98 (2014), pp. 329?351.
% [5] Dominik Alfke, Daniel Potts, Martin Stoll, and Toni Volkmer. NFFT meets Krylov methods: Fast matrix-vector products for the graph Laplacian of fully connected networks. Frontiers in Applied Mathematics and Statistics, 4:61, 2018.
%
% This software is distributed under the GNU General Public License v2. See 
% COPYING for the full license text. If that file is not available, see 
% <http://www.gnu.org/licenses/>.
%
% Copyright (c) 2020 Kai Bergermann, Toni Volkmer

clear all

% add paths.
addpath('../Subroutines')
addpath('../Subroutines/fastsum')

ratio_known_labels = 0.05;
sigma1 = 1*8000;
sigma2 = 2*1095;
sigma1 = 8000/2;
sigma2 = 1095/2;
k = 120;
p = -10;
nrepeat = 100;

filename = sprintf('Pavia_center_51x_2bands_det_coord_k%d_rep%d.mat',k,nrepeat);

fprintf('Pavia center 51 x 2 bands (det.) + coord. sigma1=%d, sigma2=%d, p=%d, k=%d, known=%.2f, nrepeat=%d start\n', sigma1, sigma2, p, k, ratio_known_labels, nrepeat);

accuracy_total_vector = [];
accuracy_classwise_vector = [];
used_bands = cell(1,nrepeat);

rng('default');
rng(1);

random_state_before = rng;

irepeat = 0;
bands = cell(1,51);
for i=1:51
  bands{i} = [i, i+51];
end
fprintf('%d/%d bands = [%d %d, ...]\n', irepeat, nrepeat, bands{1}(1), bands{1}(2));
tEigs = tic;
[lambda,phi,time_eigs,pavia_labels_vec_reduced,labels,n_class] = ...
    Pavia_center_run_eigs(bands,1,sigma1,sigma2,k,p);
timeEigs = toc(tEigs);
fprintf('time eigs: %.3f\n', timeEigs);

avg_timeAC = 0;
  %%
for irepeat = 1:nrepeat

used_bands{irepeat} = bands;

fprintf('%d/%d bands = [%d %d, ...]\n', irepeat, nrepeat, bands{1}(1), bands{1}(2));

tAC = tic;
[accuracy_total,accuracy_classwise,U_sol,it] = Pavia_center_run_ac(pavia_labels_vec_reduced,ratio_known_labels,lambda,phi,labels,n_class);
timeAC = toc(tAC);
avg_timeAC = avg_timeAC + timeAC / nrepeat;

fprintf('%d/%d bands = [%d %d]: accuracy: %.4f, runtime: %.3f\n', irepeat, nrepeat, bands{1}(1), bands{1}(2), accuracy_total, timeAC);

accuracy_total_vector = [accuracy_total_vector; accuracy_total];
accuracy_classwise_vector = [accuracy_classwise_vector; accuracy_classwise];

clear accuracy_total accuracy_classwise U_sol it
save(filename);

end

fprintf('Pavia center 51 x 2 bands (det.) + coord. sigma1=%d, sigma2=%d, p=%d, k=%d, known=%.2f, nrepeat=%d end\n', sigma1, sigma2, p, k, ratio_known_labels, nrepeat);
fprintf('Mean accuracy: %.3f +- %.3f\n', mean(accuracy_total_vector), std(accuracy_total_vector));
