require File.dirname(__FILE__) + '/../spec_helper'

describe VCardigan::Property do
  let(:vcard) { VCardigan.create }
  let(:name) { :email }
  let(:value) { 'joe@strummer.com' }
  let(:params) { { :type => 'uri' } }

  describe '#init' do
    context 'without a group' do
      let(:prop) { VCardigan::Property.create(vcard, name, value, params) }

      it 'should set the name' do
        prop.name.should == name.to_s.downcase
      end

      it 'should set the value' do
        prop.values.first.should == value
      end
    end
  end

  describe '#values' do
    let(:prop) { VCardigan::Property.create(vcard, name, value) }
    
    it 'should return the values array' do
      prop.values.should == prop.instance_variable_get(:@values)
    end
  end

  describe '#value' do
    let(:name) { :n }
    let(:value) { 'Strummer' }
    let(:another_value) { 'Joe' }
    let(:prop) { VCardigan::Property.create(vcard, name, value, another_value) }

    context 'without an index' do
      it 'should return the first item from the values array' do
        prop.value.should == prop.instance_variable_get(:@values).first
      end
    end

    context 'with an index' do
      it 'should return the item corresponding to the index' do
        prop.value(1).should == prop.instance_variable_get(:@values)[1]
      end
    end
  end

  describe '#params' do
    let(:prop) { VCardigan::Property.create(vcard, name, value, params) }

    it 'should return the params array' do
      prop.params.should == prop.instance_variable_get(:@params)
    end
  end

  describe '#param' do
    let(:prop) { VCardigan::Property.create(vcard, name, value, params) }

    context 'with a param that exists' do
      it 'should return the param' do
        prop.param(:type).should == params[:type]
      end
    end

    context 'with a param that does not exist' do
      it 'should return nil' do
        prop.param(:random).should == nil
      end
    end
  end

  describe '#to_s' do
    let(:group) { :item1 }
    let(:prop) { VCardigan::Property.create(vcard, "#{group}.#{name}", value, params) }

    it 'should return the property vCard formatted' do
      prop.to_s.should == "#{group}.#{name.upcase};TYPE=#{params[:type]}:#{value}"
    end

    context 'with properties that return long strings' do
      let(:value) { 'qwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwertqwert' }
      let(:prop) { VCardigan::Property.create(vcard, "#{group}.#{name}", value, params) }

      it 'should line fold at 75 chars' do
        prop.to_s.split("\n").each do |line|
          line.length.should <= 75
        end
      end

      context 'when chars option is set to 50' do
        let(:chars) { 50 }
        let(:vcard) { VCardigan.create(:chars => chars) }
        let(:prop) { VCardigan::Property.create(vcard, "#{group}.#{name}", value, params) }

        it 'should line fold at 50 chars' do
          prop.to_s.split("\n").each do |line|
            line.length.should <= 50
          end
        end
      end

      context 'when chars option is set to 0' do
        let(:chars) { 0 }
        let(:vcard) { VCardigan.create(:chars => chars) }
        let(:prop) { VCardigan::Property.create(vcard, "#{group}.#{name}", value, params) }

        it 'should not line fold' do
          ret = "#{group}.#{name.upcase};TYPE=#{params[:type]}:#{value}"
          prop.to_s.split("\n").length.should == 1
          prop.to_s.length.should == ret.length
        end
      end
    end

  end

  describe '#parse' do
    let(:group) { :item1 }
    let(:string) { "#{group}.#{name.upcase};TYPE=#{params[:type]}:#{value}" }
    let(:prop) { VCardigan::Property.parse(vcard, string) }

    it 'should set the group' do
      prop.group.should == group.to_s.downcase
    end

    it 'should set the name' do
      prop.name.should == name.to_s.downcase
    end

    it 'should set the values' do
      prop.values.should == [value]
    end
  end

end
