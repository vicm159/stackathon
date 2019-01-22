import React, {Component} from 'react'
import axios from 'axios'
import {Link} from 'react-router-dom'

class FirstGuess extends Component {
  constructor() {
    super()
    this.state = {
      housing: [],
      YourGuess: 0,
      slide: 0,
      img: ''
    }
    this.handleChange = this.handleChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  handleChange(evt) {
    this.setState({
      [evt.target.name]: evt.target.value
    })
  }
  getBase64(url) {
    return axios
      .get(url, {
        responseType: 'arraybuffer'
      })
      .then(response => Buffer.from(response.data, 'binary').toString('base64'))
  }

  handleSubmit(evt) {
    evt.preventDefault()
    this.getBase64('http://localhost:8081/graph/city').then(response => {
      this.setState({
        img: 'data:image/png;base64,' + response
      })
    })
    this.setState({
      slide: 1
    })
  }

  renderNextSection() {
    if (this.state.slide === 1) {
      return (
        <div>
          <li>Zillow Estimate is: {this.state.housing[0].zillowEstimate1}</li>
          <li>
            and the Linear model predicted:
            {this.state.housing[0].lm_predict}
          </li>
          <li>
            Lets see what the house is currently selling for: www.zillow.com{
              this.state.housing[0].url
            }
          </li>
          <br />
        </div>
      )
    } else {
      return <div>click submit to see the answer</div>
    }
  }

  async componentDidMount() {
    let newHouse = await axios.get('http://localhost:8081/firstHouse')
    this.setState({
      housing: newHouse.data
    })
  }

  render() {
    if (!this.state.housing[0]) {
      return <div>Loading....</div>
    }
    const {beds, baths, city, sqft, url} = this.state.housing[0]

    return (
      <div>
        <h2>Guess This House Price</h2>
        <p>
          Its got {beds} beds, {baths} baths, and it's {sqft} sqft
        </p>
        <span style={{fontWeight: 'bold'}}>its also located in {city}</span>
        <form onChange={this.handleChange}>
          YourGuess:{' '}
          <input type="integer" name="YourGuess" value={this.state.YourGuess} />
          <button onClick={this.handleSubmit} type="submit">
            Submit
          </button>
        </form>
        {this.renderNextSection()}
        <img src={this.state.img} style={{paddingBottom: 10}} />
      </div>
    )
  }
}
export default FirstGuess
