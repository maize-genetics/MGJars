test_that("Enum() returns correct data and exceptions", {
    CONSTANTS <- Enum(
        list(
            PATH_A = "path_to_a",
            PATH_B = "path_to_b",
            THRESHOLD = 10
        )
    )
    
    expect_equal(length(CONSTANTS), 3)
    expect_error(Enum(LETTERS))
    expect_error(CONSTANTS$PATH_A <- 2)
})
