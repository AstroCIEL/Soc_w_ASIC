TEST_MODE=int_ff

cd ./software && make clean && cd ..
cd ./sim && make clean && cd ..

# input_data.h is regenerated from DPRL_V14_AXU/data_for_axu/*.txt by
# software/app/my_axu_test/app.mk before main.c is compiled.
# Generator script: zzc_workspace_axu/file_format_transform/gen_input_data_axu.py

cd ./software && make my_mxu_test MXU_TEST_MODE=$TEST_MODE 
cd ..

cd ./sim && make vcs-wave \
                 app=../software/build/bin/my_mxu_test \
                 FILELIST=filelist_minimum_my_mxu_axu.f \
         && cd ..

cp ./sim/uart0.log ./sim/uart_logs/test_mxu_${TEST_MODE}_uart0.log