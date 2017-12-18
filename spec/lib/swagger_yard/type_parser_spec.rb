require 'spec_helper'

RSpec.describe SwaggerYard::TypeParser do
  subject { described_class.new }

  context "#parse" do

    it { parses 'object' }

    it { parses 'Foo' }

    it { parses 'Foo::Bar' }

    it { parses 'array<string>' }

    it { parses 'array< string >' }

    it { parses 'array<Foo::Bar>' }

    it { parses 'object<name:string,email:Foo::Bar>' }

    it { parses 'object< name : string  ,  email :   string  >' }

    it { parses 'object<name:string,email:string,string>' }

    it { parses 'object<name: string , email: string ,  string  >' }

    it { parses 'object<pairs:array<object<right:integer,left:integer>>>' }

    it { parses 'enum<one,two,three>' }

    it { parses 'enum< one, two, three >' }

    it { parses 'integer<int32>' }

    it { parses 'regexp<blah>' }

    it { parses 'regex<blah>' }

    it { parses 'regexp<^.*$>' }

    it { parses 'regexp<.\\>.>' }

    it { parses 'regexp< a b c >' }

    it { does_not_parse 'Foo::Bar,array<Hello>' }

    it { does_not_parse 'enum<array<string>>' }

    it { does_not_parse 'integer<int32,int64>' }

    it { does_not_parse 'regexp<.>.>' }

    it { does_not_parse 'regexp<.\\\\>.>' }

    it { expect_parse_to 'Foo' => { identifier: 'Foo' } }

    it { expect_parse_to 'Foo::Bar' => { identifier: 'Foo::Bar' } }

    it { expect_parse_to 'object' => { identifier: 'object' } }

    it { expect_parse_to 'array<string>' => { array: { identifier: 'string' } } }

    it { expect_parse_to 'enum<one>' => { enum: { value: 'one' } } }

    it { expect_parse_to 'regexp<^.*$>' => { regexp: '^.*$' } }

    it { expect_parse_to 'enum<one, two, three>' => { enum: [{ value: 'one' }, { value: 'two'}, { value: 'three'}] } }

    it { expect_parse_to 'regexp<^.*$>' => { regexp: '^.*$' } }

    it { expect_parse_to 'regexp<.\>.>' => { regexp: '.\>.' } }

    it { expect_parse_to 'regexp< a b c >' => { regexp: ' a b c ' }  }

    it { expect_parse_to 'regex< a b c >' => { regexp: ' a b c ' }  }

    it { expect_parse_to 'object<a:integer,b:boolean>' => { object: [{ pair: { property: 'a', type: { identifier: 'integer' } } },
                                                                     { pair: { property: 'b', type: { identifier: 'boolean' } } }] } }

    it { expect_parse_to 'object<integer>' => { object: { additional: { identifier: 'integer' } } } }

    it {
      expect_parse_to 'object<pairs:array<object<right:integer,left:integer>>>' => {
        object: {
          pair: { property: 'pairs',
              type: { array: {
                  object: [{ pair: { property: 'right', type: { identifier: 'integer' }}},
                           { pair: { property: 'left',  type: { identifier: 'integer' }}}]
                } } } }
      }
    }

    it {
      expect_parse_to 'object<a:string,b:string,object>' => {
        object: [{ pair: { property: 'a', type: { identifier: 'string' }}},
                 { pair: { property: 'b', type: { identifier: 'string' }}},
                 { additional: { identifier: 'object' }}]
      }
    }

    it { expect_parse_to 'integer<int32>' => { formatted: { name: 'integer', format: 'int32' } } }

  end

  context "#json_schema" do

    def expect_json_schema(hash)
      hash.each do |k,v|
        expect(subject.json_schema(k)).to eq(v)
      end
    end

    it { expect_json_schema 'integer' => { "type" => "integer" } }

    it { expect_json_schema 'object' => { "type" => "object" } }

    it { expect_json_schema 'Object' => { "type" => "object" } }

    it { expect_json_schema 'array' => { "type" => "array", "items" => { "type" => "string" } } }

    it { expect_json_schema 'Array' => { "type" => "array", "items" => { "type" => "string" } } }

    ["float", "double"].each do |t|
      it { expect_json_schema t => { "type" => "number", "format" => t } }
    end

    ["date-time", "date", "time", "uuid"].each do |t|
      it { expect_json_schema t => { "type" => "string", "format" => t } }
    end

    it { expect_json_schema 'float' => { "type" => "number", "format" => "float" } }

    it { expect_json_schema 'integer<int32>' => { "type" => "integer", "format" => "int32" } }

    it { expect_json_schema 'regexp<^.*$>' => { "type" => "string", "pattern" => "^.*$" } }

    it { expect_json_schema 'regexp<.\\>.>' => { "type" => "string", "pattern" => ".>." } }

    it { expect_json_schema 'regexp<.\\\\\\>.>' => { "type" => "string", "pattern" => ".\\>." } }

    it { expect_json_schema 'regexp< a b c >' => { "type" => "string", "pattern" => " a b c " } }

    it { expect_json_schema 'Foo' => { "$ref" => "#/definitions/Foo" } }

    it { expect_json_schema 'Foo::Bar' => { "$ref" => "#/definitions/Foo_Bar" } }

    it { expect_json_schema 'array<string>' => { "type" => "array", "items" => { "type" => "string" } } }

    it { expect_json_schema 'Array<string>' => { "type" => "array", "items" => { "type" => "string" } } }

    it { expect_json_schema 'array<Foo::Bar>' => { "type" => "array", "items" => { "$ref" => "#/definitions/Foo_Bar" } } }

    it { expect_json_schema 'enum<one>' => { "type" => "string", "enum" => %w(one) } }

    it { expect_json_schema 'Enum<one>' => { "type" => "string", "enum" => %w(one) } }

    it { expect_json_schema 'enum<one,two,three>' => { "type" => "string", "enum" => %w(one two three) } }

    it {
      expect_json_schema 'object<a:integer,b:boolean>' => {
        "type" => "object",
        "properties" => {
          "a" => { "type" => "integer" },
          "b" => { "type" => "boolean" } }
      }
    }

    it {
      expect_json_schema 'object<a:integer,b:boolean,string>' => {
        "type" => "object",
        "properties" => {
          "a" => { "type" => "integer" },
          "b" => { "type" => "boolean" } },
        "additionalProperties" => { "type" => "string" }
      }
    }

    it {
      expect_json_schema 'array<object<a:integer,b:boolean>>' => {
        "type" => "array",
        "items" => {
          "type" => "object",
          "properties" => {
            "a" => { "type" => "integer" },
            "b" => { "type" => "boolean" } }
        }
      }
    }
  end
end
