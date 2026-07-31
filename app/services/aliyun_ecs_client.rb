# frozen_string_literal: true
# Aliyun ECS API client — talks to Alibaba Cloud Elastic Compute Service.
# Uses AccessKey + Secret for signature-based auth (HMAC-SHA1).
#
# API docs: https://www.alibabacloud.com/help/en/ecs/api-reference
class AliyunEcsClient
  BASE_URL = "https://ecs.%s.aliyuncs.com"

  def initialize(access_key:, secret_key:, region: "cn-hangzhou")
    @ak = access_key
    @sk = secret_key
    @region = region
  end

  # List all ECS instances in this region
  def describe_instances
    resp = call("DescribeInstances", { RegionId: @region, PageSize: 50 })
    instances = resp.dig("Instances", "Instance") || []
    instances.map { |i| parse_instance(i) }
  end

  # Start an instance
  def start_instance(instance_id)
    call("StartInstance", { InstanceId: instance_id })
  end

  # Stop an instance
  def stop_instance(instance_id)
    call("StopInstance", { InstanceId: instance_id })
  end

  # Reboot an instance
  def reboot_instance(instance_id)
    call("RebootInstance", { InstanceId: instance_id })
  end

  private

  def parse_instance(data)
    {
      instance_id:    data["InstanceId"],
      name:           data["InstanceName"],
      instance_type:  data["InstanceType"],
      status:         map_status(data["Status"]),
      public_ip:      data.dig("PublicIpAddress", "IpAddress")&.first,
      private_ip:     data.dig("VpcAttributes", "PrivateIpAddress", "IpAddress")&.first,
      zone:           data["ZoneId"],
      cpu:            data["Cpu"],
      memory:         data["Memory"],
      os_name:        data["OSName"],
      created_at:     data["CreationTime"]
    }
  end

  def map_status(aliyun_status)
    case aliyun_status
    when "Running" then :running
    when "Stopped" then :stopped
    when "Starting" then :provisioning
    when "Stopping" then :stopping
    else :unknown
    end
  end

  def call(action, params = {})
    require "net/http"
    require "uri"
    require "json"
    require "time"
    require "openssl"
    require "base64"

    params = params.merge(
      "Action" => action,
      "Version" => "2014-05-26",
      "Format" => "JSON",
      "Timestamp" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
      "SignatureMethod" => "HMAC-SHA1",
      "SignatureVersion" => "1.0",
      "SignatureNonce" => SecureRandom.hex(16),
      "AccessKeyId" => @ak
    )

    # Build canonical query string
    canonical = params.sort.map { |k, v| "#{encode(k)}=#{encode(v)}" }.join("&")
    string_to_sign = "GET&#{encode('/')}&#{encode(canonical)}"
    signature = Base64.strict_encode64(
      OpenSSL::HMAC.digest("sha1", "#{@sk}&", string_to_sign)
    )
    url = "#{BASE_URL % @region}/?#{canonical}&Signature=#{encode(signature)}"

    resp = Net::HTTP.get_response(URI(url))
    JSON.parse(resp.body)
  end

  def encode(str)
    ERB::Util.url_encode(str.to_s).gsub("+", "%20").gsub("*", "%2A").gsub("%7E", "~")
  end
end
