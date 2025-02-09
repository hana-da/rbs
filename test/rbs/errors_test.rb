require "test_helper"

class RBS::ErrorsTest < Test::Unit::TestCase
  def buffer(source)
    RBS::Buffer.new(content: source, name: "test.rbs")
  end

  def test_parse_signature_with_parsing_error_detailed_message
    omit "Exception#detailed_message does not supported" unless Exception.method_defined?(:detailed_message)

    assert_raises RBS::ParsingError do
      RBS::Parser.parse_signature(buffer(<<~RBS))
        class Foo
          deff bar: () -> void
        end
      RBS
    end.tap do |exn|
      assert_equal <<~DETAILED_MESSAGE, exn.detailed_message
        test.rbs:2:2...2:6: Syntax error: unexpected token for class/module declaration member, token=`deff` (tLIDENT) (RBS::ParsingError)

            deff bar: () -> void
            ^^^^
      DETAILED_MESSAGE
    end
  end

  def test_parse_type_with_parsing_error_detailed_message
    omit "Exception#detailed_message does not supported" unless Exception.method_defined?(:detailed_message)

    assert_raises RBS::ParsingError do
      RBS::Parser.parse_type(buffer("singleton(foo)"))
    end.tap do |exn|
      assert_equal <<~DETAILED_MESSAGE, exn.detailed_message
        test.rbs:1:10...1:13: Syntax error: expected one of class/module/constant name, token=`foo` (tLIDENT) (RBS::ParsingError)

          singleton(foo)
                    ^^^
      DETAILED_MESSAGE
    end
  end

  def test_parse_method_type_with_parsing_error_detailed_message
    omit "Exception#detailed_message does not supported" unless Exception.method_defined?(:detailed_message)

    assert_raises RBS::ParsingError do
      RBS::Parser.parse_method_type(buffer("()) -> void"))
    end.tap do |exn|
      assert_equal <<~DETAILED_MESSAGE, exn.detailed_message
        test.rbs:1:2...1:3: Syntax error: expected a token `pARROW`, token=`)` (pRPAREN) (RBS::ParsingError)

          ()) -> void
            ^
      DETAILED_MESSAGE
    end
  end
end
