@testset "xtile" begin

    df = dropmissing(DataFrame(PalmerPenguins.load()))

    # -- test on strings!
    a = xtile(df.species, 2)
    b = xtile(df.species, 2; weights=Weights(repeat([1], inner=nrow(df))))
    @test a==b
    @test sum(a)==520

    # -- test for more xtile than categories
    a = xtile(df.species, 4);
    b = xtile(df.species, 5);
    @test a==b

    # -- test on int
    a = xtile(df.flipper_length_mm, 2);
    @test sum(a)==173
    b = xtile(df.flipper_length_mm, 10);
    @test sum(b)==1539
    c = xtile(df.flipper_length_mm, 100);
    @test sum(c)==16923
    d = xtile(df.flipper_length_mm, 10, weights=Weights(repeat([1], inner=nrow(df))));
    @test d==b
    e = xtile(df.flipper_length_mm, 10, weights=Weights(rand(nrow(df))));
    @test sum(e.<=10)==nrow(df)

    # -- test on Float
    a = xtile(df.bill_depth_mm, 2);
    @test sum(a)==173
    b = xtile(df.bill_depth_mm, 10);
    @test sum(b)==1533
    c = xtile(df.bill_depth_mm, 100);
    @test sum(c)==16741
    d = xtile(df.bill_depth_mm, 10, weights=Weights(repeat([1], inner=nrow(df))));
    @test d==b
    e = xtile(df.bill_depth_mm, 10, weights=Weights(rand(nrow(df))));
    @test sum(e.<=10)==nrow(df)


end