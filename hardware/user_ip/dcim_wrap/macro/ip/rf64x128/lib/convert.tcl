# 获取当前路径下所有的 .lib 文件
set lib_files [glob *.lib]

foreach lib $lib_files {
    # 替换后缀名生成 db 文件名
    set db_name [string map {.lib .db} $lib]
    
    # 读入 lib 文件
    read_lib $lib
    
    # 【修复处】：提取集合中真实的库名称（字符串）
	set current_lib [file rootname $lib]
    
    # 打印提示信息，方便监控进度
    echo "Writing database for library: $current_lib"
    
    # 写出 db 文件
    write_lib -format db $current_lib -output $db_name
    
    # 清理内存，防止读取多个库导致命名冲突或内存溢出
    remove_lib $current_lib
}
