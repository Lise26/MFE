patients = [1,9,24,26];
%window_sizes = [250, 2500];
window_sizes = 2500;
%measures = ["cc", "corr_cc", "wPLI"];
measures = ["cc", "corr_cc"];

for i = measures
    for j = window_sizes
        params = EEGData.empty(4,0);
        p = 1;
        for k = patients
            fprintf("PATIENT %d\n", k)
            if k < 10
                file = "Files/0" + k + "/"; 
            else
                file = "Files/" + k + "/";
            end
            
            eeg = EEGData(file, 8);
            param = eeg.process_data(i, j);

            params(p) = param;

            % Average values for the parameters
            fprintf("------- Parameters for patient n° %d\n", k);
            fprintf("Network density: %12.8f\n", param.Av_density)
            fprintf("Clustering coefficient: %12.8f\n", param.Av_clustering_coeff)
            fprintf("Path length: %12.8f\n", param.Av_char_path_length)
            fprintf("Size of largest component: %12.8f\n", param.Av_size_larg_comp)
            fprintf("Path length of largest component: %12.8f\n", param.Av_char_path_length_lc)
            fprintf("Independent components: %12.8f\n", param.Av_nb_ind_comp)
            fprintf("Small world configuration: %12.8f\n", param.Av_small_world)

        end

        p1 = [params(1).Density, params(1).Clustering_coeff, params(1).Char_path_length, params(1).Size_larg_comp, params(1).Char_path_length_lc, params(1).Nb_ind_comp, params(1).Small_world];
        p9 = [params(2).Density, params(2).Clustering_coeff, params(2).Char_path_length, params(2).Size_larg_comp, params(2).Char_path_length_lc, params(2).Nb_ind_comp, params(2).Small_world];
        p24 = [params(3).Density, params(3).Clustering_coeff, params(3).Char_path_length, params(3).Size_larg_comp, params(3).Char_path_length_lc, params(3).Nb_ind_comp, params(3).Small_world];
        p26 = [params(4).Density, params(4).Clustering_coeff, params(4).Char_path_length, params(4).Size_larg_comp, params(4).Char_path_length_lc, params(4).Nb_ind_comp, params(4).Small_world];
        
        x = 1:7;
        measures = {'Density', 'Clustering coefficient', 'Path length', 'Largest component', 'Path length of largest component', 'Number of components', 'Small-world'};
        figure();
        plot(x,p1,"*")
        hold on
        plot(x,p9,"*")
        hold on
        plot(x,p24,"*")
        hold on
        plot(x,p26,"*")
        hold off
        set(gca,'XTick',1:7,'XTickLabel',measures)
        ylabel("Parameters values")
        legend("Patient n°1", "Patient n°9", "Patient n°24", "Patient n°26")
        title("Network parameters for different patients")
        xlim([0 8])
        set(gcf, 'units','normalized','outerposition',[0 0 1 1])
    end
end