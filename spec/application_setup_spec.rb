describe 'dotenv' do
  it 'includes a .env file with an EVENTFUL_KEY' do
    expect(ENV['EVENTFUL_KEY']).to_not be_nil
  end
end

