cd ./software && make clean && cd ..
cd ./sim && make clean && cd ..


cd ./software && make mxu_idma_gbuf_test 
cd ..


cd ./sim && make vcs-wave \
                 app=../software/build/bin/mxu_idma_gbuf_test \
                 FILELIST=filelist_minimum_my_mxu_axu.f \
         && cd ..

cp ./sim/uart0.log ./sim/uart_logs/test_idma_gbuf_uart0.log