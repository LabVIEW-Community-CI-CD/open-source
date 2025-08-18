Describe 'Dispatcher Args Inputs' {
    $meta = @{
        requirement = 'REQ-000'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/Dispatcher.ArgsInputs.Tests.ps1'
    }

    It 'dummy test' -Tag 'REQ-000' {
        $true | Should -BeTrue
    }
}
