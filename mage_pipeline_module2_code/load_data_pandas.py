import io
import pandas as pd
import requests
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data_from_api(*args, **kwargs):
    """
    Template for loading data from API
    """
    urls = [
        'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-10.csv.gz',
        'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-11.csv.gz',
        'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-12.csv.gz'
    ]
    # response = requests.get(url)
    taxi_dtypes = {
        'VendorID': pd.Int64Dtype(),
        'Passenger_count': pd.Int64Dtype(),
        'Trip_distance': float,
        'PULocationID': pd.Int64Dtype(),
        'DOLocationID': pd.Int64Dtype(),
        'RateCodeID': pd.Int64Dtype(),
        'Store_and_fwd_flag': str,
        'Payment_type': float,
        'Fare_amount': float,
        'Extra': float,
        'MTA_tax': float,
        'Improvement_surcharge': float,
        'Tip_amount': float,
        'Tolls_amount': float,
        'Total_amount': float,
        'Trip_type': pd.Int64Dtype()}

    parse_dates = ['lpep_pickup_datetime', 'lpep_dropoff_datetime']

    df = pd.DataFrame()

    #df = pd.read_csv("https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2020-10.csv.gz")

    for url in urls:
        df = pd.concat([df, pd.read_csv(url, sep = ',', compression = 'gzip', dtype = taxi_dtypes, parse_dates = parse_dates)])

    #return pd.read_csv(io.StringIO(response.text), sep=',')
    #return pd.read_csv(url, sep = ',', compression = 'gzip', dtype = taxi_dtypes, parse_dates = parse_dates)
    return df


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
