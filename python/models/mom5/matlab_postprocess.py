from pathlib import Path
from tqdm import tqdm

import matlab.engine
import os
import shutil

def matlab_postprocess(base_model_out: Path):
    ntile = 38
    # assemble output files into one locations
    name = base_model_out.stem
    root = base_model_out.parent

    assembled_transport_output_folder = root / 'ocean_transport_out'
    assembled_transport_output_folder.mkdir(exist_ok=True)

    print("Assembling transport files...")
    for i in range(1,ntile+1):
        current_tile = "{}_{:02d}".format(name,i)
        current_output_tile = root / current_tile

        assembled_file = assembled_transport_output_folder / "transport_{:02d}.nc".format(i)
        
        assembled_file.symlink_to(current_output_tile / "output051" / "ocean" / "ocean_transport.nc") #TODO: cant just alwasy take 51


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





