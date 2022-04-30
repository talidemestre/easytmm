from pathlib import Path
from tqdm import tqdm

import matlab.engine
import os
import subprocess

def matlab_postprocess(base_model_output_dir: Path, matlab_data: Path, output_dir: Path, initial_conditions_path: Path, ntiles: int, deltaT: int):
    '''Given outputs of model, perform postprocessing to generate TMM-driver ready transport matrices.'''
    name = base_model_output_dir.stem
    archive = base_model_output_dir.parent

    assembled_transport_output_folder = archive / 'ocean_transport_out'
    assembled_transport_output_folder.mkdir(exist_ok=True)

    # Assemle transport files from model runs into one directory for processing.
    print("Assembling transport files...")
    for i in range(1,ntiles+1):
        current_tile = "{}_{:02d}".format(name,i)
        current_output_tile = archive / current_tile

        highest_output = os.popen('ls ' + str(current_output_tile) + " | grep '^output[0-9]\+$' |  sort -n | tail -n1").read()[:-1]

        assembled_file = assembled_transport_output_folder / "transport_{:02d}.nc".format(i)
        
        assembled_file.symlink_to(current_output_tile / highest_output / "ocean" / "ocean_transport.nc") #TODO: dont do this if the model failed


    print("Running matlab postprocess scripts...")
    eng = matlab.engine.start_matlab()

    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "matlab_tmm" / "gcmfaces")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "matlab_tmm" / "Misc")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "matlab_tmm" / "TMM")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "Matrix_extraction_code")),nargout=0)
    eng.GetTransport(str(assembled_transport_output_folder), int(ntiles), nargout=0) # converts the netcdf output from the model into Matlab Matrix files
    eng.get_transport_matrix_all(str(assembled_transport_output_folder), nargout=0) # combines the many individual tile matrices into a single matrix for each month
    eng.test_TMs_ann_filter(str(matlab_data), str(assembled_transport_output_folder), deltaT, nargout=0) # test the matrices for stability
    eng.make_input_files_for_periodic_mom(str(assembled_transport_output_folder), str(matlab_data), initial_conditions_path, deltaT, nargout=0) # output transport matrices as petsc files

    # move output files from working directory to output directory
    subprocess.check_call('mv [ABN][eid]*_[0-1][0-9] ' + str(output_dir), shell=True)
    subprocess.check_call('mv Ndini.petsc ' + str(output_dir), shell=True)
