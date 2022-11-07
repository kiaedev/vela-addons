import (
	"strings"
)

"k-istio-gateway": {
	alias: "kigw"
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "networking.istio.io/v1beta1"
		kind:       "Gateway"
	}
	description: "istio gateway"
	labels: {}
	type: "component"
}

template: {
	customPorts: [ for idx, cp in parameter.customPorts {
		{
			hosts: parameter.hosts
			port: {
				name:     strings.ToLower("\(cp.protocol):\(cp.port)")
				number:   cp.port
				protocol: cp.protocol
			}
		}
	}]

	output: {
		apiVersion: "networking.istio.io/v1beta1"
		kind:       "Gateway"
		spec: {
			selector: {
				istio: "ingressgateway"
			}
			if !parameter.httpsEnabled {
				servers: [{
					hosts: parameter.hosts
					port: {
						name:     "http:80"
						number:   80
						protocol: "HTTP"
					}
				}] + customPorts
			}
			if parameter.httpsEnabled {
				servers: [{
					hosts: parameter.hosts
					port: {
						name:     "http:80"
						number:   80
						protocol: "HTTP"
					}
					tls: httpsRedirect: parameter.httpsRedirect
				}, {
					hosts: parameter.hosts
					port: {
						name:     "https:443"
						number:   443
						protocol: "HTTPS"
					}
					tls: {
						mode:           "SIMPLE"
						credentialName: "gateway-cert"
					}
				}] + customPorts
			}
		}
	}
	outputs: {}
	parameter: {

		hosts: [...string]

		httpsEnabled: *false | bool

		httpsRedirect: *false | bool

		customPorts: [...{
			port: number

			protocol: string
		}]
	}
}
