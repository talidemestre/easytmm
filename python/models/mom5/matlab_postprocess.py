from pathlib import Path
from tqdm import tqdm

import matlab.engine
import os
import shutil
import subprocess

def matlab_postprocess(base_model_out: Path, ntiles: int):
    # assemble output files into one locations
    name = base_model_out.stem
    root = base_model_out.parent

    temp = base_model_out.parent.parent
    scratch_dir = temp / 'scratch' # TODO: Pass down from above.
    matlab_data = scratch_dir / "matlab_data"

    assembled_transport_output_folder = root / 'ocean_transport_out'
    assembled_transport_output_folder.mkdir(exist_ok=True)

    print("Assembling transport files...")
    for i in range(1,ntiles+1):
        current_tile = "{}_{:02d}".format(name,i)
        current_output_tile = root / current_tile

        highest_output = os.popen('ls ' + str(current_output_tile) + " | grep '^output[0-9]\+$' |  sort -n | tail -n1").read()[:-1] # TODO: duped functionality


        assembled_file = assembled_transport_output_folder / "transport_{:02d}.nc".format(i)
        
        assembled_file.symlink_to(current_output_tile / highest_output / "ocean" / "ocean_transport.nc")


    print("Running matlab postprocess scripts...")
    # run matlab scripts
    eng = matlab.engine.start_matlab()

    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "matlab_tmm" / "gcmfaces")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "matlab_tmm" / "Misc")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "matlab_tmm" / "TMM")),nargout=0)
    eng.addpath("{}".format(str(Path(__file__).parent / "matlab_scripts" / "Matrix_extraction_code")),nargout=0)
    eng.GetTransport(str(assembled_transport_output_folder), nargout=0)
    eng.get_transport_matrix_all(str(assembled_transport_output_folder), nargout=0)
    eng.test_TMs_ann_filter(str(matlab_data), str(assembled_transport_output_folder), nargout=0)
    eng.make_input_files_for_periodic_mom(str(assembled_transport_output_folder), str(scratch_dir / "matlab_data"), '/scratch/v45/tm8938/projects/easytmm/sst_access_om2.nc', nargout=0)

    subprocess.check_call('mv [ABN][eid]*_[0-1][0-9] ' + str(temp.parent), shell=True)
    subprocess.check_call('mv Ndini.petsc ' + str(temp.parent), shell=True)
