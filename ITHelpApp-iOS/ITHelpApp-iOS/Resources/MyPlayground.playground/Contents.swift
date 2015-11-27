//: Playground - noun: a place where people can play

import Cocoa

var x = [Int]()
x.append(0)
x.append(2)
x.append(3)

func checkX(inout arr: [Int]) -> Bool {
    return (arr == x)
}

var a = [0, 2, 3]
var b = x
a == x
b == x

checkX(&a)
checkX(&b)
b.append(4)
checkX(&b)
checkX(&x)
x.append(5)
checkX(&x)

func addNum(inout arr: [Int]) -> Bool {
    arr.append(7)
    return checkX(&arr)
}

addNum(&a)
addNum(&b)
addNum(&x)