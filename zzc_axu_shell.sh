cd ./software && make clean && cd ..
cd ./sim && make clean && cd ..

# input_data.h is regenerated from DPRL_V14_AXU/data_for_axu/*.txt by
# software/app/my_axu_test/app.mk before main.c is compiled.
# Generator script: zzc_workspace_axu/file_format_transform/gen_input_data_axu.py

cd ./software && make my_axu_test && cd ..

cd ./sim && make vcs-run \
                 app=../software/build/bin/my_axu_test \
                 FILELIST=filelist_minimum_my_mxu_axu.f \
         && cd ..

