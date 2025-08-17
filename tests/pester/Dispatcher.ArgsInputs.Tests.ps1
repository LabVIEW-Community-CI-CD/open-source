Describe 'Dispatcher Args Inputs' {
    BeforeEach { Add-TestResult -Property @{ Owner = "DevTools"; Evidence = "tests/pester/Dispatcher.ArgsInputs.Tests.ps1" } }
    It 'dummy test' {
        $true | Should -BeTrue
    }
}
