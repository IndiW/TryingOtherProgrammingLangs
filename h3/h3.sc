
def isPrime(n: Int) = {
    var x: Boolean = true
    for(i <- Range(2,n/2)){
        if (n % i == 0) x = false
    }
    x
}

def isPalindrome[A](a: List[A]) = {
    var b = a.reverse
    b == a
}

def digitList(a: Int): List[Int]={
    a match{
        case 0 => List()
        case _ => {
            val ones = a%10
            List.concat(digitList((a-ones)/10),List(ones))
        }
    }
}


def primePalindrome(a: Int)={
    var ret = false
    if (isPrime(a)){
        ret = isPalindrome(digitList(a))
    }
    ret
}


