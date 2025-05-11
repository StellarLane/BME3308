#import "@preview/rubber-article:0.3.1": *

#show: article.with(
  show-header: true,
  header-titel: "嵌入式计算机系统与实验 | 作业2",
  eq-numbering: "(1.1)",
  eq-chapterwise: true,
)

#maketitle(
  title: text("嵌入式计算机系统与实验 | 作业2", font: "SimHei"),
  authors: ("Shuiyuan@Noroshi",),
)

= 汇编代码试运行
我们尝试运行下段代码
```yasm
ORG 0000H
LJMP START
ORG 040H
	
	START:	 
	MOV SP, #5FH ;设堆栈
	
	LOOP:  	
	NOP
  LJMP LOOP ;循环

END ;结束
```
分别将第三行设为```yasm ORG 040H```和 ```YASM ORG 100H```, 推测其会将程序分别存储在程序存储器的`0x0040`和`0x0100`处
在编译后观察`C:0` 的内存情况
#figure(
	image("image-17.png"),
	caption: "可以注意到操作码是完全一样的, 但位置发生了改变, 这与我们的预期是相同的"
)
指令操作码分别为:
- ```yasm MOV SP, #5FH```, 分别为75(MOV) 81(SP所在地址) 5F(立即数), 位于ROM的0x0040\~0x0042处(以上段代码内容为准)
- ```yasm NOP``` 操作码为00, 位于0x0043
- ```yasm LJMP LOOP``` 操作码为02(LJMP) 00 43(LJMP的目标地址), 位于0x0044\~0x0046

#figure(
	image("image-18.png"),
	caption: "sp变化与PC轨迹"
)
如上图我们可见, 在执行了`MOV`指令后sp发生了变化; 而SP指针是执行一次增加一起, 其增加的距离就是指令的长度, 例如上面我们看见`MOV`指令的长度为3, 所以在执行完之后就从40跳到了43, 而NOP就仅+1, 而在LJMP之后程序指针又指回了标签开始处

`START`和`LOOP`则为程序标签, 本身是什么名字都无所谓, 在这个程序里, `START`是程序开始的标志, 和c语言里的main函数比较类似, 而`LOOP`则是一个死循环, 防止程序运行到不该运行的地方

= 四则运算对PSW相关比特的影响

== ```yasm error 65: access violation at : no 'execute/read' permission```
在我想手写一段验证四则运算的代码的时候, 弹出了标题这样的报错信息
```yasm
ORG 0000H
LJMP START

START:
	MOV A, #01H
	MOV B, #02H
	ADD A, B
END
```
我感到很疑惑, 因为我认为这段代码是没有什么任何问题的. END也是正常写了的. 但查询资料后发现, 这里的END是一个伪指令, 其并不会被编译, 当然也不会实际上对代码执行任何影响. 代码会一直按顺序执行, 当执行到未写入程序的部分时就会报错, 从某种意义上除非在程序中设定死循环不然最终都会以无权限结束?
不过END会对编译的内容有影响, 在END之后的代码都不会被编译, 如下片代码与上的编译后的内容是完全一样的.
```yasm
ORG 0000H
LJMP START

START:
	MOV A, #01H
	MOV B, #02H
	ADD A, B
END
	
FOO:
	WHAT DOES THIS LINE MEAN?
	NO ONE KNOWS AND NO ONE CARES!
```
#figure(
  image("image.png"),
  caption: "如图可见, 两段代码在编译后存入内存的机器码是完全一样的"
)

回归正题, 我们在这个实验中重点关注的是在四则运算中PSW寄存器特别是其中的P位, AC位, CY位, OP位的行为

== 加法运算
=== CY位与OP位
在.a51汇编程序中, 似乎并没有像C语言中的```c unsigned int```与```c int```这种区别, 例如```11111111B```可以表示-1(有符号, 补码形式), 也可以表示255(无符号, 正常二进制表示). 具体是那个似乎只能程序员自己清楚? 二者在实际的寄存器表示中没有区别. 而OV主要是为了有符号数的加减而设计的, CY主要是为了无符号数的加减而设计的, 比如下面两个例子:
```yasm
ADD_1_1:
	MOV A, #01000000B ;有符号数+64/+127, 无符号数64/255
	MOV B, #01000000B ;有符号数+64/+127, 无符号数64/255
	ADD A, B          ;有符号则为+128/+127溢出, 无符号为128/255正常
ADD_1_2:
	MOV A, #01000000B ;有符号数+64/+127, 无符号数64/255
	MOV B, #11000000B ;有符号数-64/-128, 无符号数192/255
	ADD A, B          ;有符号为0/+127正常, 无符号为256/255溢出
```
那么我们可以看出, 在```ADD_1_1```程序段中, 如果把A, B视为有符号数则会发生溢出, 而视为无符号数则可以正常完成加法; 而在```ADD_1_2```程序段中, 如果把A, B视为有符号数则可以正常完成加法; 而视为无符号数则会发生溢出, 那么观察实际调试时的寄存器结果, 也确实如此.
#figure(
  image("image-2.png"),
  caption: "如图可见, 左边为第一次加法运算后, 可以注意到OV变为1, 而CY置零, 说明在有符号情况下出现了溢出而无符号正常. 
  同理右边为完成第二次加法运算后, 可以注意到OV置零, 而CY变为1, 即说明在有符号情况下正常, 而无符号情况下发生了溢出."
)
=== P位与AC位
P位为校验位, 用于检测寄存器A的数(二进制状态)下1的个数, 若为奇数则为1, 偶数则为0. 而AC位是半进位, 即第四位是否发生了进位, 若发生了则为1否则位0, 为了验证其实际表现, 我们考虑以下例子
```yasm
ADD_2:
	MOV A, #00001001B
	MOV B, #00001101B
	ADD A, B
```
从结果我们可以看出, 本来为0的P位(A原先有2个1, 现在变为了3)所以变为了1, 而第四位发生了进位, AC=1
#figure(
	image("image-3.png", width: 40%),
	caption: "如图, 执行后的p, ac均发生了变化"
)

=== ADDC
```yasm ADDC```的作用即是考虑CY位的进位状况, 如下片代码

```yasm
ADD_3:
	SETB CY
	CLR OV
	MOV A, #01111110B
	MOV B, #00000001B
	ADDC A, B
```
如果只考虑A, B的话, 那么既不会触发OV也不会触发CY, 但在CY为1时使用ADDC指令, 我们发现CY的进位被加在了A, B之上, 在这片代码里, 也就是触发了OV=1.
#figure(
	image("image-4.png", width: 40%),
	caption: "如图, 发现执行指令之后P位为1, 说明了CY的1位也计入了运算"
)
== 减法运算
```yasm SUBB```, .a51中的减法同样带有借位功能, 具体来说, 其将减去CY位的值, 其他位的行为与加法相似, 考虑如下代码片段:
```yasm
SUBB_1:
	MOV PSW, #00H
	MOV A, #10000001B
	MOV B, #00000001B
	SUBB A, B
SUBB_2:
	MOV PSW, #00H
	SETB CY
	MOV A, #10000001B
	MOV B, #00000001B
	SUBB A, B
```
#figure(
	image("image-5.png", width: 40%),
	caption: "如图我们可以发现, 在第一段代码并没有中CY位为0, 所以实际减法为-127-1=-128, 可以正常执行不触发一处操作, 而第二段代码由于CY位被设为了1, 实际减法位-127-1-1=-129 < -128, 超过了8位补码的表示范围, 因此触发了OV溢出提示"
)
== 乘法运算
乘法的行为与加减稍有不同, 首先是从指令方面```yasm MUL AB```, AB是连一起的没有分开, 且乘法默认是无符号数相乘, 其次在结果方面, 由于乘法运算大概率大概率结果>255, 所以此处会把A, B都作为储存结果的寄存器, 其中A储存低八位, B储存高八位, 若结果>255则会将OV设为1, CY在乘法运算中不会发生变化, 我们以以下代码为例:
```yasm
MUL_1:
	MOV PSW, #00H
	MOV A, #00000001B
	MOV B, #00000001B
	MUL AB
MUL_2:
	MOV PSW, #00H 
	MOV A, #10000000B
	MOV B, #00000010B
	MUL AB
```
第一个为1*1, 即最后得到1, 未溢出到高八位; 第二个为128*2, 发生了溢出, 同时也可以观察到高八位存入了数值
#figure(
	image("image-6.png"),
	caption: "第一个乘法运算后结果为0x0001, 亦没有发生OV溢出的情况;
	而第二次结果为0x0100, 可见高八位(B寄存器)的数值发生了改变, 同时OV也变为了1"
)

== 除法运算
除法的操作逻辑与乘法类似, 不过其A寄存器存商, B寄存器存余数, 若除数为0则触发OV, 例如以下代码
```yasm
DIV_1:
	MOV PSW, #00H
	MOV A, #10000001B
	MOV B, #00000010B
	DIV AB
DIV_2:
	MOV PSW, #00H
	MOV A, #11111111B
	MOV B, #00000000B
	DIV AB
```
第一个应该是129/2=64余1, 第二个则会触发OV
#figure(
	image("image-7.png"),
	caption: "可以观察第一次运算后A寄存器为0x40(十进制64), B寄存器位0x01, 分别为商和余数
	第二个除法运算由于除数为0, 所以触发了OV"
)

= 指针与堆栈
== 函数
堆栈最常用到的地方就是在函数调用的时候, 所以首先我们应当对.a51中的函数有一个基本的概念, 当然这里的函数其实和标签基本是一个东西, 一个简单例子如下
```yasm
ORG 0000H
LJMP MAIN

ORG 0033
	
MY_FUNCTION:
	MOV A, #01H
	RET
	
MAIN:
	MOV A, #05H
	CALL MY_FUNCTION
```
当执行到```yasm CALL MY_FUNCTION```时, 其会跳转至```YASM MY_FUNCTION```处, 然后执行对应语句, 直到这里都是与```YASM LJMP```到标签是一样的, 不过如果有```YASM RET```语句, 则其会直接返回到原```YASM CALL MY_FUNCTION```的位置继续向后执行. 

.a51中的函数并没有像c语言等高级语言中复杂的传参机制与类型, 其就是简单粗暴地覆盖寄存器中的原数值, 因此堆栈等机制就能发挥上用场了.
#figure(
	image("image-8.png"),
	caption: "如图, 本来在MAIN部分对A寄存器已有赋值, 而该赋值在调用MY_FUNCTION的时候被直接覆盖了"
)

== PUSH与POP
栈以及其通用的push和pop操作在数据结构课程中早已有了一些基本的了解, 在a51汇编语言中, PUSH/POP的格式是```yasm PUSH/POP <ADDR>```, 需要强调的点就是这里的操作的是直接地址, 例如说, `A`是累加器的缩写, 但是说```YASM PUSH A```是不行的, 必须要用A的的全称(ACC)或者其直接地址0E0H才行. 此外, 此处的寻址是数据存储器中的, 不是程序存储器中的. 另外PUSH和POP的对象不一定是相同的, 很可能(处于特别目的或者只是不小心), 你把本来是ACC的PUSH进去之后POP到B里去了. 下面这段代码就简单体现了PUSH, POP的特性
```yasm
	MOV A, #12H
	MOV B, #34H
	PUSH ACC
	MOV A, #56H
	PUSH PSW
	POP B
	POP ACC
```
#figure(
	image("image-9.png"),
	caption: "如图可以看见, 在第一次PUSH之后, sp自增; 而在两次POP之后, sp回到自己最初的位置, 而b被PSW覆盖(PUSH, POP位置不同), 而A本来是0x12, 后来被MOV覆盖为了0x56, 在POP之后又变回了0
	x12"
)
我们考虑一个包含函数的情况:
```YASM
TEST_FUNCTION:
	PUSH ACC
	PUSH B
	MUL AB
	MOV R0, A
	POP B
	POP ACC
	RET
	
MAIN:
	MOV A, #03H
	MOV B, #05H
	CALL TEST_FUNCTION
```
我们知道乘法运算中A, B都会用于存储结果, 而这段代码利用函数机制和堆栈让结果存在一般寄存器里, 保留了A, B中的原操作数
#figure(
	image("image-10.png"),
	caption: "从左上开始, 我们可以看见操作为3*5, 在函数体内, 我们先将A, B的数值存入栈中, 然后进行乘法(右上), 再把结果转移至r0(左下), 然后再将保存在栈中的原操作数出栈(右下)"
)

== 程序指针与存储器结构
程序指针(PC)是单片机中比较特殊的一类寄存器, 其指向当前正在执行的命令对应的操作数的存储地址(程序存储器内), 且其一般不能被手动改动.
数据存储器中存储寄存器等存储部分的数值, 其中00H\~1FH的共32个地址包含了四组每组8个寄存器, 具体使用那组由PSW寄存器中的第4, 5位决定, 之后20H到2FH位的16个地址为位地址区, 这里的每个地址可以被视作八个二进制地址单独操作(这部分地址实际上被写作00H~7FH), 之后为通用RAM区和堆栈区.考虑下段代码:
```yasm
PROGCOUNT:
	MOV PSW, #0000000B
	MOV R0, #05H
	MOV R1, #03H
	MOV PSW, #00001000B
	MOV R0, #06H
	MOV R1, #04H
	SETB 00H
	SETB 07H
```
#figure(
	image("image-12.png"),
	caption: "注意左图程序指针的数值0x002C, 而通过反汇编我们可以看见此时即将执行的MOV指令就是处在0x002C的地方, 并且此指令占了3个地址, 因此在完成执行后PC指针直接向后跳了三位跳到了0x002F"
)
#figure(
	image("image-13.png"),
	caption: "理论上左右执行的两段代码都是向R0, R1存入了数据, 但是我们可以看见此处我们中途更改了一次PSW值, 故实际上是存入了两组寄存器中. 这个在右下角的的数据存储器中也可以看出来, 05, 03; 06, 04分别存入了0x00, 0x01, 0x08, 0x09中, 并没有发生覆盖"
)
#figure(
	image("image-14.png"),
	caption: "此处如果我们是使用的SETB这种针对一位的操作的话, 其会自动将后面的地址理解位地址中的对应位(例如00H实际上是对应的20H的第一位), 即此处我们可以看见我们在SETB 00H, SETB 07H后得到的结果是20H位为81, 也就是10000001B."
)

== 更多例子
```yasm
ORG 0000H
LJMP START
ORG 040H
	
	START:
	MOV 	SP,	#5FH
  MOV 	A,	#69H 
  MOV 	B,  #12H
  PUSH   	ACC
  PUSH   	B
	MOV 	A,	#0H 
  MOV 	B,  #0H
  POP		B
  POP  	ACC
	
	LOOP:
	NOP
  LJMP 	LOOP
	END

```
#figure(
	image("image-19.png"),
	caption: "运行结果, 可见其很好地体现了在堆栈对寄存器中数值的保护"
)
= 数字键盘控制的7段LED显示
== 原理
7段LED灯, 顾名思义就是由7段LED灯管组成的, 可以显示0\~9数字的LED灯管, 其可以用7个I/O端口控制, 不同组合(即不同的接口电位的高低状态组合)则会使其显示不同的数字

矩阵键盘, 同样用7个接口与单片机连接(矩阵键盘规格为3\*4, 即三个接口接列, 四个接口接行), 我们会首先对所有的I/O口加上高电平, 然后我们会对某一行/列接口加上低电平, 若该行/列有按钮被按下, 则对应所在列/行的出口接口同样会为低电平
== 代码与电路
```yasm
ORG 0000H
AJMP START

ORG 0040H
START:   
	MOV P0, #00H
TEST:     
	MOV P2, #0FFH
	
    CLR P2.3
		JNB P2.2, NUM1
		JNB P2.1, NUM2
		JNB P2.0, NUM3
    SETB P2.3
    CLR P2.4
		JNB P2.2, NUM4
        JNB P2.1, NUM5
        JNB P2.0, NUM6
    SETB P2.4
    CLR P2.5
        JNB P2.2, NUM7
        JNB P2.1, NUM8
        JNB P2.0, NUM9
    SETB P2.5
    CLR P2.6
         JNB P2.1, NUM0
	SETB P2.6
    SJMP TEST
	
NUM0:     
	MOV P0,#3FH
    SJMP TEST
NUM1:     
	MOV P0,#06H
    SJMP TEST         
NUM2:     
	MOV P0,#5BH
    SJMP TEST
NUM3:     
	MOV P0,#4FH
    SJMP TEST
NUM4:     
	MOV P0,#66H
    SJMP TEST
NUM5:     
	MOV P0,#6DH
    SJMP TEST
NUM6:     
	MOV P0,#7DH
    SJMP TEST
NUM7:     
	MOV P0,#07H
	SJMP TEST
NUM8:
	MOV P0,#7FH
    SJMP TEST
NUM9:     
	MOV P0,#6FH
    SJMP TEST
END
```

#figure(
	image("image-15.png", width: 80%),
	caption: "7段LED与矩阵键盘的电路"
)

== 运行效果
我们把代码产生的hex文件载入电路模拟中, 可以发现其有按照我们的目标运行

#figure(
	image("image-16.png", width: 80%),
	caption: "通过观察电位指示与LED显示, 可以认为电路行为符合我们预期"
)