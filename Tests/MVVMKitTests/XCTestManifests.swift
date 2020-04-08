import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(MVVMKitTests.allTests),
        ]
    }
#endif
