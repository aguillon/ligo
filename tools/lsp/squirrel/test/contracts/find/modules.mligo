module B = struct
    type titi = int
end

module A = struct
    type titi = B.titi
    module C = struct
        let toto: titi = 42
    end
    let add (a:titi) (b:titi) : titi = a + b
end

module D = A

let toto : D.titi =
    module E = D.C in
    E.toto

let add ((a,b): A.titi * D.titi) : A.titi = A.add a b
