from typing import List

def encode( strs: List[str]) -> str:
    r = ""
    for s in strs:
        r=r+str(len(s))+"#"+s
    return r

def decode( s: str) -> List[str]:
    r = []
    i=0
    while(i<len(s)):
        j=i
        while s[j]!="#":
            j+=1
        c = int(s[i:j])
        r.append(s[j+1:j+1+c])
        i=j+1+c
    return r

# strs=["we","say",":","yes","!@#$%^&*()"]
# print(encode(strs))


s= "2#we3#say1#:3#yes10#!@#$%^&*()"
print(decode(s))