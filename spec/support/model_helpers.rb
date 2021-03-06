shared_examples 'attribute' do
  let(:setter) { "#{attribute}=" }

  it 'is read only' do
    expect(subject).to_not respond_to setter
  end
end

shared_examples 'Lol model' do
  let(:subject_class) { subject.class }

  describe '#new' do
    it "takes an option hash as argument" do
      expect { subject_class.new valid_attributes }.not_to raise_error
    end

    it 'raises an error if an attribute is not allowed' do
      expect { subject_class.new({ :foo => :bar }) }.to raise_error NoMethodError
    end

    it 'sets the given option hash as #raw' do
      expect(subject_class.new(valid_attributes).raw).to eq valid_attributes
    end
  end

  describe '#raw' do
    it_behaves_like 'attribute' do
      let(:attribute) { 'raw' }
    end
  end
end

shared_examples 'plain attribute' do
  let(:subject_class) { subject.class }
  let(:setter) { "#{attribute}=" }

  it_behaves_like 'attribute'

  context 'during #new' do
    it 'is set if the hash contains the attribute name "underscored"' do
      model = subject_class.new attribute => attribute_value
      expect(model.send attribute).to eq attribute_value
    end

    it 'is set if the hash contains the attribute name "camelized"' do
      model = subject_class.new camelize(attribute) => attribute_value
      expect(model.send attribute).to eq attribute_value
    end
  end
end

shared_examples 'collection attribute' do
  let(:subject_class) { subject.class }
  let(:setter) { "#{attribute}=" }

  it_behaves_like 'attribute'

  it 'is sets if the hash contains the attribute name "underscored"' do
    model = subject_class.new({ attribute => [{}, {}] })
    expect(model.send(attribute).size).to eq 2
  end

  it 'is set if the hash contains the attribute name "camelized"' do
    model = subject_class.new({ camelize(attribute) => [{}, {}] })
    expect(model.send(attribute).size).to eq 2
  end

  context 'if the value is not enumerable' do
    it 'raises an error' do
      expect {
        subject_class.new({ attribute => 'asd' })
      }.to raise_error NoMethodError
    end
  end

  context 'if the value is enumerable' do
    context 'and contains items as Hash' do
      it 'parses the item' do
        model = subject_class.new attribute => [{}]
        expect(model.send(attribute).map(&:class).uniq).to eq [attribute_class]
      end
    end

    context 'and contains items as non-Hash' do
      it 'does not parse the item' do
        model = subject_class.new attribute => [attribute_class.new, Object.new]
        expect(model.send(attribute).map(&:class).uniq).to eq [attribute_class, Object]
      end
    end
  end
end