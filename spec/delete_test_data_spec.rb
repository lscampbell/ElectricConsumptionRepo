describe 'test data cleanup' do
  before :each do
    Customer.create(name:'test-customer')
    Customer.create(name:'test-customer')
    Customer.create(name:'test-customer2')
    Customer.create(name:'test-customer-another')
  end

  it 'should delete  /test-customer' do
    delete '/test-customer'
    expect(Customer.where(name: 'test-customer').all).to be_empty
    end

  it 'should delete  /test-customer2' do
    delete '/test-customer2'
    expect(Customer.where(name: 'test-customer2').all).to be_empty
  end

  it 'should not delete  /test-customer-another' do
    delete '/test-customer-another'
    expect(Customer.where(name: 'test-customer-another').all).to_not be_empty
  end
end