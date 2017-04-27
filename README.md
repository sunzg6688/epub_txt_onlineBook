# epub_txt_onlineBook
这是一个用 as3 实现的用于解析 epub txt 格式的内容，然后在线生成电子书的完整项目。<br>
1.技术点是epub类型的文件一般是xml或者html文件的压缩文件，需要先解压拿到文件，并读取文件包含的数据，再根据文档结构在flash中生成对应的虚拟文档结构，然后根据flash提供的api，把虚拟的文档结构在flash中展现出来，即相当于用flash完成部分文档结构的输出展示。<br>
2.在flash中通过鼠标点击拖拽书本的四个角落，模拟真实书本翻页效果。

测试地址：http://sunzg6688.github.io/epub_txt_onlineBook/bin-debug/EPubExampleD.html;
