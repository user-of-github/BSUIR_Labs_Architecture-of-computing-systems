#pragma clang diagnostic push
#pragma ide diagnostic ignored "openmp-use-default-none"
#include <iostream>
#include <omp.h>


const std::size_t kThreadNumber{10};
const std::size_t kRowsPerThread{120};
const constexpr std::size_t kMatrixSize{kThreadNumber * kRowsPerThread};


typedef struct
{
    std::size_t first_row;
    std::size_t last_row;
} TDATA, *PTDATA;


int op1[kMatrixSize][kMatrixSize];
int op2[kMatrixSize][kMatrixSize];
int res[kMatrixSize][kMatrixSize];


void initialize_operands();

void stdoutput_result();

int thread_multiplier(PTDATA data);


int main()
{
    PTDATA pThreadData[kThreadNumber];

    initialize_operands();

    for (std::size_t counter{0}; counter < kThreadNumber; ++counter)
    {
        //initializing TDATA params
        pThreadData[counter] = new TDATA;

        pThreadData[counter]->first_row = kRowsPerThread * counter;
        pThreadData[counter]->last_row = kRowsPerThread * (counter + 1) - 1;
    }

    #pragma omp parallel for
    for (std::size_t i = 0; i < kThreadNumber; ++i)
    {
        std::cout << "\nStarted thread # " << omp_get_thread_num() << '\n';
        thread_multiplier(pThreadData[i]);
        std::cout << "\nFinished thread # " << omp_get_thread_num() << '\n';
    }


    std::cout << "\nmultiplication finished\n";
    //stdoutput_result();

    return 0;
}


int thread_multiplier(PTDATA data)
{
    const auto first_row{data->first_row};
    const auto last_row{data->last_row};

    for (std::size_t i{first_row}; i <= last_row; ++i)
    {
        for (std::size_t j = 0; j < kMatrixSize; ++j)
        {
            res[i][j] = 0;

            for (std::size_t k = 0; k < kMatrixSize; ++k)
                res[i][j] += op1[i][k] * op2[k][j];
        }
    }

    return 0;
}

void initialize_operands()
{
    for (std::size_t row{0}; row < kMatrixSize; ++row)
        for (std::size_t col{0}; col < kMatrixSize; ++col)
            op1[row][col] = op2[row][col] = 1;
}

void stdoutput_result()
{
    for (std::size_t i{0}; i < kMatrixSize; ++i)
    {
        for (std::size_t j{0}; j < kMatrixSize; ++j)
            std::cout << res[i][j] << ' ';

        std::cout << '\n';
    }
}
