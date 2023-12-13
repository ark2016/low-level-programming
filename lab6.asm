assume cs: code, ds: data
include in.inc

data segment
    buf db 100 dup (?)
    string db 0 ,100 dup(?)
    resmsg db 20 dup(?)
    symbol db 0
    in_put db 'input.txt', 0
    out_put db 'output.txt', 0
    filesize dw 512
    handle dw ?
    handle2 dw ?
    res dw 0
data ends
 
stack segment Stack
    db 100h dup(?)
stack ends

code segment
start:	
    mov ax, data
    mov ds, ax

    open in_put, handle
    create out_put, handle2
    read handle, filesize, buf
    input buf, string, symbol

    counting string, symbol
    mov [res], dx
    print resmsg, res


    write handle2, filesize, resmsg
    
    close handle
    close handle2
	mov ah, 4ch
	int 21h
code ends
end start
